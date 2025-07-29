//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 16.07.2025.
//

import Foundation
import PhotosUI
import UIKit
import RxSwift
import RxRelay

public protocol MediaSelectionProtocol: UIViewController & UINavigationControllerDelegate, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate {
    var selectedImageRelay: BehaviorRelay<(UIImage, String)?> { get }
    var viewDisposeBag: DisposeBag { get }
}

public extension MediaSelectionProtocol {
    func openCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .authorized:
            showCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { [weak self] in
                    if granted {
                        self?.showCamera()
                    } else {
                        self?.showAccessDeniedAlert()
                    }
                }
            }
        default:
            showAccessDeniedAlert()
            break
        }
    }
    
    func showCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Камера недоступна на устройстве.")
            return
        }

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = false

        present(picker, animated: true, completion: nil)
    }
    
    func showAccessDeniedAlert() {
        let alert = UIAlertController(
            title: nil,
            message: "Please allow camera access in Settings to use this feature.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL)
        }))
        present(alert, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        GalleryMediaPicker.handlePickedResults(ofType: UIImage.self, typeIdentifiers: [UTType.image.identifier], result: result)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] image, url in
                let imageName = url.lastPathComponent
                self?.selectedImageRelay.accept((image, imageName))
                
            } onFailure: { error in
                print(error)
            }
            .disposed(by: viewDisposeBag)
    }
}
