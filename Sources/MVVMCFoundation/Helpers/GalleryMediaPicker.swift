//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 16.07.2025.
//

import Foundation
import PhotosUI
import RxSwift

public final class GalleryMediaPicker {
    public static func displayPicker(from viewController: UIViewController, filter: PHPickerFilter, with delegate: PHPickerViewControllerDelegate) {
            PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                return
            }
            
            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            let filter = filter
            configuration.filter = filter
            configuration.preferredAssetRepresentationMode = .compatible
            configuration.selectionLimit = 1
            
            DispatchQueue.main.async {
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = delegate
                viewController.present(picker, animated: true)
            }
        }
    }
    
    public static func handlePickedResults<T: NSItemProviderReading>(ofType: T.Type, typeIdentifiers: [String], result: PHPickerResult) -> Single<(T, URL)> {
        let itemProvider = result.itemProvider
        
        return Single.zip(
            itemProvider.rxLoadMediaFile(ofType: T.self),
            itemProvider.rxLoadMediaFilePath(for: typeIdentifiers)
        )
    }
    
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
    
    public static func saveVideoToGallery(at url: URL) -> Single<Void> {
        self.downloadVideo(from: url)
            .map { self.saveVideoToDocuments(url: $0, fileName: url.lastPathComponent) }
            .flatMap { url in
                guard let url = url else {
                    return .error(NSError(domain: "Saving file to documents failed", code: -1))
                }
                
                return Single.create { single in
                    PHPhotoLibrary.requestAuthorization { status in
                        guard status == .authorized || status == .limited else {
                            try? FileManager.default.removeItem(at: url)
                            single(.failure(NSError(domain: "User denied access to photos", code: -1)))
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
                            try? FileManager.default.removeItem(at: url)
                        }
                    }
                    
                    return Disposables.create()
                }
            }
    }
    
    public static func saveVideoToDocuments(url: URL, fileName: String) -> URL? {
        let fileManager = FileManager.default
        let directory = fileManager.temporaryDirectory
        let fileURL = directory.appendingPathComponent(fileName)
        
        do {
            try fileManager.copyItem(at: url, to: fileURL)
            print("video saved successfully")
            return fileURL
        } catch {
            print("saving video to directory failed with error: \(error)")
            return nil
        }
    }
    
    public static func downloadVideo(from url: URL) -> Single<URL> {
        Single.create { single in
            let task = URLSession.shared.downloadTask(with: url) { location, response, error in
                if let error = error {
                    single(.failure(NSError(domain: "Failed while downloading data from url: \(error.localizedDescription)", code: -1)))
                    return
                }
                
                guard let location = location else {
                    single(.failure(NSError(domain: "Got nil location after downloading data", code: -1)))
                    return
                }
                
                single(.success(location))
            }
            task.resume()
            
            return Disposables.create { task.cancel() }
        }
    }
}
