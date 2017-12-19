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
    typealias RepositoryErrorCallback = (Error) -> Void

    func save(podcast: Podcast, onProgress: @escaping ProgressCallback, onSucces: @escaping RepositorySuccessCallback, onFailure: @escaping RepositoryErrorCallback)
    func updateSaved(for podcast: Podcast)
    func checkIfSaved(for podcast: Podcast) -> Bool
    func retrieveMP3(for podcast: Podcast)
}

public class OfflineDownloadsManager: NSObject, OfflineDownloadsProtocol {
    public func save(podcast: Podcast,
                     onProgress: @escaping OfflineDownloadsProtocol.ProgressCallback,
                     onSucces: @escaping OfflineDownloadsProtocol.RepositorySuccessCallback,
                     onFailure: @escaping OfflineDownloadsProtocol.RepositoryErrorCallback) {
        let utilityQueue = DispatchQueue.global(qos: .utility)

        Alamofire.download(podcast.mp3)
            .downloadProgress(queue: utilityQueue) { progress in
                onProgress(progress.fractionCompleted)
            }
            .responseData { response in
                if let data = response.result.value {
                    self.saveToDisk(data, onSuccess: {
                        onSucces()
                    }, onFailure: { (error) in
                        onFailure(error)
                    })
                }
        }
    }

    private func saveToDisk(_ data: Data, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try Disk.save(data, to: .documents, as: DiskKeys.OfflineDownloads.folderPath)
                DispatchQueue.main.async {
                    onSuccess()
                }
            } catch let error {
                onFailure(error)
            }
        }
    }

    public func updateSaved(for podcast: Podcast) {
        
    }

    public func checkIfSaved(for podcast: Podcast) -> Bool {
        return false
    }

    public func retrieveMP3(for podcast: Podcast) {

    }
}
