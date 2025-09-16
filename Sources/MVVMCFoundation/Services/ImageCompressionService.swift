//
//  ImageCompressionService.swift
//  MVVMCFoundation
//
//  Created by катенька on 11.09.2025.
//


import Foundation
import UIKit

protocol ImageCompressionService {
    func compressImageData(_ data: Data, maxFileSize: Int) -> Data?
}

public final class JPEGCompressionService: ImageCompressionService {
    public init() {}
    
    public func compressImageData(_ data: Data, maxFileSize: Int) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        
        var quality = 1.0
        var compressedData = data
        while compressedData.count > maxFileSize {
            quality -= 0.1
            guard let data = image.jpegData(compressionQuality: quality) else { return nil }
            compressedData = data
        }
        
        return compressedData
    }
}
