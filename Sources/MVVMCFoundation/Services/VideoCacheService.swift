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
    
    public func getCachedVideoURL(for url: URL) -> Single<URL> {
        let fileName = url.lastPathComponent
        let cacheFilePath = cacheDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: cacheFilePath.path()) {
            return Single.just(cacheFilePath)
            
        } else {
            return downloadVideo(from: url, to: cacheFilePath)
        }
    }
    
    public func clearCache() -> Single<Void> {
        Single.create { single in
            do {
                try FileManager.default.removeItem(at: self.cacheDirectory)
                try FileManager.default.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
                
                single(.success(()))
                
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
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
    
    private func downloadVideo(from remoteURL: URL, to localURL: URL) -> Single<URL> {
        Single.create { single in
            let task = URLSession.shared.downloadTask(with: remoteURL) { url, _, error in
                guard let url,
                      error == nil else {
                    single(.failure(error!))
                    return
                }
                
                do {
                    try FileManager.default.moveItem(at: url, to: localURL)
                    single(.success(localURL))
                    
                } catch {
                    single(.failure(error))
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
