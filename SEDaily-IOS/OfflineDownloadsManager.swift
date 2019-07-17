//
//  OfflineDownloadsManager.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 11/21/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import Disk
import Alamofire

public enum OfflineDownloadsError: Error {
}

public protocol OfflineDownloadsProtocol {
    typealias ProgressCallback = (Double) -> Void
    typealias RepositorySuccessCallback = () -> Void
    typealias RepositoryErrorCallback = (Error?) -> Void

    func save(podcast: PodcastViewModel, onProgress: @escaping ProgressCallback, onSuccess: @escaping RepositorySuccessCallback, onFailure: @escaping RepositoryErrorCallback)
    func deletePodcast(podcast: PodcastViewModel, completion: @escaping () -> Void)
    static func findURL(for podcast: PodcastViewModel) -> URL?
}

public class OfflineDownloadsManager: NSObject, OfflineDownloadsProtocol {
    static let sharedInstance = OfflineDownloadsManager()

    private lazy var backgroundManager: Alamofire.SessionManager = {
        let bundleIdentifier = "com.sed"
        return Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: bundleIdentifier + ".background"))
    }()

    private var downloadRequests: [String: DownloadRequest] = [:]

    public func save(podcast: PodcastViewModel,
                     onProgress: @escaping OfflineDownloadsProtocol.ProgressCallback,
                     onSuccess: @escaping RepositorySuccessCallback,
                     onFailure: @escaping OfflineDownloadsProtocol.RepositoryErrorCallback) {
        let utilityQueue = DispatchQueue.global(qos: .utility)

        guard let urlString = podcast.mp3URL?.absoluteString else {
            onFailure(nil)
            return
        }
        let fileName = podcast.getFilename()

        if let existingRequest = self.existingDownloadRequest(with: fileName) {
            existingRequest.downloadProgress(closure: { (progress) in
                DispatchQueue.main.async {
                    onProgress(progress.fractionCompleted)
                }
            }).responseData(completionHandler: { (response) in
                self.downloadRequests.removeValue(forKey: fileName)

                switch response.result {
                case .success:
                    DispatchQueue.main.async {
                        onSuccess()
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                        if error.localizedDescription == "cancelled" {
                            onFailure(nil)
                            return
                        }
                        onFailure(error)
                    }
                }
            })

            return
        }

        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            assertionFailure("No documents url found")
            onFailure(nil)
            return
        }

        let destination: DownloadRequest.DownloadFileDestination? = { _, _ in
            let fileURL = documentsURL.appendingPathComponent(fileName).appendingPathExtension("mp3")

            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path)
                } catch {
                    print("Error removing item at path: %@", fileURL.path)
                }
            }

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        let request = backgroundManager.download(urlString, to: destination)
            .downloadProgress(queue: utilityQueue) { progress in
                DispatchQueue.main.async {
                    onProgress(progress.fractionCompleted)
                }
            }
            .responseData { response in
                self.downloadRequests.removeValue(forKey: fileName)

                switch response.result {
                case .success:
                    DispatchQueue.main.async {
                        onSuccess()
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                        if error.localizedDescription == "cancelled" {
                            onFailure(nil)
                            return
                        }
                        onFailure(error)
                    }
                }
        }

        self.downloadRequests[fileName] = request
    }

    public func deletePodcast(podcast: PodcastViewModel,
                              completion: @escaping () -> Void) {
        // Cancel download request if one is active
        if self.downloadRequests.has(key: podcast.getFilename()) {
            self.downloadRequests[podcast.getFilename()]?.cancel()
        }
        
        guard let fileStringToDelete = podcast.downloadedFileURLString else {
            completion()
            return
        }
        do {
            try FileManager.default.removeItem(atPath: fileStringToDelete)
            completion()
        } catch {
            print("Could not clear file because of error: \(error.localizedDescription)")
            completion()
        }
    }

    public static func findURL(for podcast: PodcastViewModel) -> URL? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            assertionFailure("No documents url found")
            return nil
        }
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            let files = fileURLs.filter { $0.pathExtension == "mp3" }

            let urls = files.filter { $0.lastPathComponent.deletingPathExtension == podcast.getFilename() }

            return urls.first
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }

    private func existingDownloadRequest(with name: String) -> DownloadRequest? {
        return downloadRequests[name]
    }
}
