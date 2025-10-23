//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 16.10.2025.
//

import Photos
import RxSwift

public enum PhotoAccessState {
    case authorized
    case limited
    case notDetermined
    case denied
    case restricted
}

public protocol MediaLibraryServiceProtocol {
    func getAuthorizationStatus() -> PhotoAccessState
    func requestAccess() -> Single<PhotoAccessState>
}

public final class MediaLibraryService: MediaLibraryServiceProtocol {
    public init() {}
    
    public func getAuthorizationStatus() -> PhotoAccessState {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized:
            return PhotoAccessState.authorized
            
        case .limited:
            return PhotoAccessState.limited
            
        case .notDetermined:
            return PhotoAccessState.notDetermined
            
        case .denied:
            return PhotoAccessState.denied
            
        case .restricted:
            return PhotoAccessState.restricted
            
        @unknown default:
            return PhotoAccessState.restricted
        }
    }
    
    public func requestAccess() -> Single<PhotoAccessState> {
        Single.create { single in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .authorized:
                    single(.success(PhotoAccessState.authorized))
                    
                case .limited:
                    single(.success(PhotoAccessState.limited))
                    
                case .notDetermined:
                    single(.success(PhotoAccessState.notDetermined))

                case .denied:
                    single(.success(PhotoAccessState.denied))
                    
                case .restricted:
                    single(.success(PhotoAccessState.restricted))

                @unknown default:
                    single(.success(PhotoAccessState.restricted))
                }
            }
            
            return Disposables.create()
        }
    }
}
