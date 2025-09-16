//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 17.07.2025.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Alamofire
import PhotosUI

public final class SaveToGalleryHelper {
    public static func saveImageToGallery(_ image: UIImage) -> Single<Void> {
        Single.create { single in
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized || status == .limited else {
                    single(.failure(NSError(domain: "User denied access to photos", code: -1)))
                    return
                }
                
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    request.creationDate = Date()
                }) { success, error in
                    if success {
                        single(.success(()))
                    } else {
                        single(.failure(error!))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    public static func saveImageToGallery(from url: URL) -> Single<Void> {
        Single.create { single in
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized || status == .limited else {
                    single(.failure(NSError(domain: "User denied access to photos", code: -1)))
                    return
                }
                
                URLSession.shared.dataTask(with: url) { data, _, error in
                    guard let data = data,
                          let image = UIImage(data: data) else { return }
                    
                    PHPhotoLibrary.shared().performChanges({
                        let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                        request.creationDate = Date()
                    }) { success, error in
                        if success {
                            single(.success(()))
                        } else {
                            single(.failure(error!))
                        }
                    }
                }.resume()
            }
            
            return Disposables.create()
        }
    }
        
    public static func saveVideoToGallery(from url: URL) -> Single<Void> {
        self.downloadVideo(from: url)
            .flatMap { url in
                return Single.create { single in
                    PHPhotoLibrary.requestAuthorization { status in
                        guard status == .authorized || status == .limited else {
                            single(.failure(NSError(domain: "Access to photos denieded", code: -1)))
                            return
                        }

                        PHPhotoLibrary.shared().performChanges({
                            let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                            request?.creationDate = Date()
                        }) { success, error in
                            if success {
                                single(.success(()))
                            } else {
                                single(.failure(error!))
                            }
                        }
                    }
                    
                    return Disposables.create()
                }
            }
    }
    
    public static func downloadVideo(from url: URL) -> Single<URL> {
        let destination: DownloadRequest.Destination = { _, _ in
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileName = url.lastPathComponent
            let fileURL = tempDirectory.appendingPathComponent(fileName)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        return Single.create { single in
            AF.download(url, to: destination).response { response in
                guard let url = response.fileURL else {
                    single(.failure(response.error ?? NSError(domain: "Failed download video from server", code: 01)))
                    return
                }
                
                single(.success(url))
            }
            
            return Disposables.create()
        }
    }
}

