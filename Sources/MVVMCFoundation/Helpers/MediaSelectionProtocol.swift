//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 16.07.2025.
//

import Foundation
import PhotosUI
import RxSwift
import RxRelay

public protocol MediaSelectionProtocol: PHPickerViewControllerDelegate {
    var selectedImageRelay: BehaviorRelay<(UIImage, String)?> { get }
    var viewDisposeBag: DisposeBag { get }
}

public extension MediaSelectionProtocol {
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
