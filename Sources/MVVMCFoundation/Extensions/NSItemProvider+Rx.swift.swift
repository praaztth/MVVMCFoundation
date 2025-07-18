//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 16.07.2025.
//

import Foundation
import RxSwift

extension NSItemProvider {
    func rxLoadMediaFile<T: NSItemProviderReading>(ofType: T.Type) -> Single<T> {
        return Single.create { single in
            guard self.canLoadObject(ofClass: T.self) else {
                single(.failure(NSError(domain: "RxLoadMediaFileError: cannot load file", code: -1)))
                return Disposables.create {}
            }
            
            self.loadObject(ofClass: T.self) { image, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let image = image as? T else {
                    single(.failure(NSError(domain: "RxLoadMediaFileError: failed while loading file", code: -1)))
                    return
                }
                
                single(.success(image))
            }
            
            return Disposables.create {}
        }
    }
    
    func rxLoadMediaFilePath(for typeIdentifiers: [String]) -> Single<URL> {
        return Single.create { single in
            guard let identifier = typeIdentifiers.first(where: { self.hasItemConformingToTypeIdentifier($0) }) else {
                single(.failure(NSError(domain: "RxLoadImageNameError: item doesn't conforming to passed type identifiers", code: -1)))
                return Disposables.create()
            }
            
            self.loadFileRepresentation(forTypeIdentifier: identifier) { url, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let url = url else {
                    single(.failure(NSError(domain: "RxLoadMediaFileNameError", code: -1)))
                    return
                }
                
                single(.success(url))
            }
            
            return Disposables.create()
        }
    }
}
