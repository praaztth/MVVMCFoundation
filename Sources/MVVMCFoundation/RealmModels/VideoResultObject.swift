//
//  VideoResultObjectt.swift
//  MVVMCFoundation
//
//  Created by катенька on 29.07.2025.
//

import Foundation
import RealmSwift

final public class VideoResultObject: Object {
    @Persisted(primaryKey: true) public var id: Int
    @Persisted public var status: String
    @Persisted public var video_url: String?
    @Persisted public var date: Date
    
    public convenience init(id: Int, status: String, video_url: String?) {
        self.init()
        self.id = id
        self.status = status
        self.video_url = video_url
        self.date = Date()
    }
}
