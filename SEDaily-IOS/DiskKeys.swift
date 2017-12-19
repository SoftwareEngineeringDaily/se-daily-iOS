//
//  DiskKeys.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 11/16/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation

enum DiskKeys: String {
    case PodcastFolder = "Podcasts"
    case OfflineDownloads = "Offline-Downloads"

    var folderPath: String {
        return self.rawValue + "/" + self.rawValue + ".json"
    }
}
