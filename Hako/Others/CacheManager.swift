//
//  CacheHelper.swift
//  Hako
//
//  Created by Gao Tianrun on 14/10/25.
//

import Foundation

struct CacheHelper {
    private func calculateDirectorySize(_ url: URL) -> Int64 {
        var size: Int64 = 0
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey])
            for file in files {
                let attributes = try file.resourceValues(forKeys: [.fileSizeKey])
                size += Int64(attributes.fileSize ?? 0)
            }
        } catch {
            print("Error calculating size for \(url.lastPathComponent): \(error.localizedDescription)")
        }
        return size
    }
    
    func calculateCacheSize() -> Int64 {
        var size: Int64 = 0
        let fileManager = FileManager.default
        
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let tmpDirectory = fileManager.temporaryDirectory

        size += Int64(URLCache.shared.currentDiskUsage)
        size += calculateDirectorySize(cacheDirectory)
        size += calculateDirectorySize(tmpDirectory)
        
        return size
    }
    
    func clearCache() {
        
    }
}
