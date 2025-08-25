//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 29.07.2025.
//

import Foundation
import RealmSwift
import PixVerseAPI

final public class PhotoResultObject: Object {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var url: String
    @Persisted public var detail: String
    @Persisted public var date: Date
    
    public convenience init(id: String, url: String, detail: String) {
        self.init()
        self.id = id
        self.url = url
        self.detail = detail
        self.date = Date()
    }
    
    public convenience init(id: String, from model: PhotoResult) {
        self.init()
        self.id = id
        self.url = model.url
        self.detail = model.detail
        self.date = Date()
    }
    
    public func convertToDTO() -> PhotoResult {
        return PhotoResult(url: self.url, detail: self.detail)
    }
}
