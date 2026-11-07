//
//  ImageLoader.swift
//  Hako
//
//  Created by Gao Tianrun on 7/11/26.
//

import Foundation

enum ImageLoader {
    static let cache = URLCache(memoryCapacity: 0, diskCapacity: 300 * 1024 * 1024, directory: URL.cachesDirectory.appending(path: "ImageCache"))

    static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }()
}
