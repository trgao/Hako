//
//  CacheManager.swift
//  Hako
//
//  Created by Gao Tianrun on 14/10/25.
//

import Foundation

actor CacheManager {
    static var shared = CacheManager()
    private let formatter = ByteCountFormatter()
    private let fileManager = FileManager.default
    
    init() {
        formatter.countStyle = .file
    }
    
    private func calculateDirectorySize(_ url: URL) -> Int64 {
        var size: Int64 = 0
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
    
    private func clearDirectory(_ url: URL) {
        do {
            let files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            for file in files {
                try? fileManager.removeItem(at: file)
            }
        } catch {
            print("Error clearing \(url.lastPathComponent) directory: \(error.localizedDescription)")
        }
    }
    
    func calculateCacheSize() -> String {
        var size: Int64 = 0
        size += Int64(URLCache.shared.currentDiskUsage)
        size += calculateDirectorySize(fileManager.temporaryDirectory)
        return formatter.string(fromByteCount: size)
    }
    
    func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        clearDirectory(fileManager.temporaryDirectory)
    }
}
