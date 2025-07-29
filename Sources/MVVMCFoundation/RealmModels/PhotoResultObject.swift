//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 29.07.2025.
//


import Foundation
import RealmSwift
import PixVerseAPI

final class PhotoResultObject: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var url: String
    @Persisted var detail: String
    
    convenience init(id: UUID, url: String, detail: String) {
        self.init()
        self.id = id
        self.url = url
        self.detail = detail
    }
    
    convenience init(id: UUID, from model: PhotoResult) {
        self.init()
        self.id = id
        self.url = model.url
        self.detail = model.detail
    }
    
    func convertToDTO() -> PhotoResult {
        return PhotoResult(url: self.url, detail: self.detail)
    }
}
