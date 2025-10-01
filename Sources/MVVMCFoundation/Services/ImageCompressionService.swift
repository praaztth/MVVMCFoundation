//
//  ImageCompressionService.swift
//  MVVMCFoundation
//
//  Created by катенька on 11.09.2025.
//


import Foundation
import UIKit

protocol ImageCompressionService {
    func compressImageData(_ data: Data, maxFileSize: Int, targetSize: CGSize?) -> Data?
}

public final class JPEGCompressionService: @preconcurrency ImageCompressionService {
    public init() {}
    
    @MainActor
    public func compressImageData(_ data: Data, maxFileSize: Int, targetSize: CGSize? = nil) -> Data? {
        guard var image = UIImage(data: data) else { return nil }
        
        var size = image.size
        
        if let targetSize {
            if size.width > targetSize.width || size.height > targetSize.height {
                image = image.resize(targetSize: targetSize)
            }
        }
        
        var quality = 1.0
        guard var compressedData = image.jpegData(compressionQuality: quality) else { return nil }
        
        while compressedData.count > maxFileSize {
            quality -= 0.1
            guard let data = image.jpegData(compressionQuality: quality) else { return nil }
            compressedData = data
        }
        
        return compressedData
    }
}
