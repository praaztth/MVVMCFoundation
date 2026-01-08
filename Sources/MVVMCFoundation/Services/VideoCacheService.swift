//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 01.10.2025.
//

import Foundation
import RxSwift
import RxAlamofire

public class VideoCacheService {
    private init() {}
    
    @MainActor public static let shared = VideoCacheService()
    
    private let cacheDirectory: URL = {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let directory = caches.appending(path: "Cache", directoryHint: .isDirectory)
        
        if !FileManager.default.fileExists(atPath: directory.path()) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        
        return directory
    }()
    
    private let disposeBag = DisposeBag()
    
    public func getCachedVideoURL(for url: URL, callback: @escaping (URL?) -> Void) {
        let fileName = url.lastPathComponent
        let cacheFilePath = cacheDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: cacheFilePath.path()) {
            callback(cacheFilePath)
            
        } else {
            downloadVideo(from: url, to: cacheFilePath) { url in
                callback(url)
            }
        }
    }
    
    public func clearCache() {
        do {
            try FileManager.default.removeItem(at: self.cacheDirectory)
            try FileManager.default.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
            
        } catch {
            Logger.shared.log(error.localizedDescription)
            print(error)
        }
    }
    
    public func cacheSize() -> Int64 {
        var size: Int64 = 0
        
        if let files = try? FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            for file in files {
                if let fileSize = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    size += Int64(fileSize)
                }
            }
        }
        
        return size
    }
    
    private func downloadVideo(from remoteURL: URL, to localURL: URL, callback: @escaping (URL?) -> Void) {
        URLSession.shared.downloadTask(with: remoteURL) { url, _, error in
            guard let url,
                  error == nil else {
                callback(nil)
                return
            }
            
            if FileManager.default.fileExists(atPath: localURL.path()) {
                callback(localURL)
                return
            }
            
            do {
                try FileManager.default.moveItem(at: url, to: localURL)
                callback(localURL)
                
            } catch {
                callback(nil)
                print(error)
            }
        }.resume()
    }
}
