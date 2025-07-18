//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 17.07.2025.
//

import Foundation
import AVFoundation
import UIKit
import RxSwift

public final class ThumbnailGeneratorHelper {
    public static func generateThumbnail(from url: URL, atSecond second: Double) -> Observable<UIImage> {
        return Observable.create { observer in
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            let time = CMTime(seconds: second, preferredTimescale: 600)
            
            imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, _, error in
                if let error = error {
                    print(error)
                    observer.onError(NSError(domain: "Error generating thumbnail: \(error.localizedDescription)", code: -1))
                    observer.onCompleted()
                    return
                }
                
                guard let cgImage = cgImage else {
                    observer.onError(NSError(domain: "Empty cgImage after generation thumbnail", code: -1))
                    observer.onCompleted()
                    return
                }
                
                let image = UIImage(cgImage: cgImage)
                observer.onNext(image)
                observer.onCompleted()
            }
            
            return Disposables.create {}
        }
    }
}
