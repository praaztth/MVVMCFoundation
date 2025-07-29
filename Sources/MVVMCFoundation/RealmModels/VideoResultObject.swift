//
//  VideoResultObjectt.swift
//  MVVMCFoundation
//
//  Created by катенька on 29.07.2025.
//


import RealmSwift
import PixVerseAPI

final class VideoResultObject: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var status: String
    @Persisted var video_url: String?
    
    convenience init(id: Int, status: String, video_url: String?) {
        self.init()
        self.id = id
        self.status = status
        self.video_url = video_url
    }
    
    convenience init(id: Int, from model: VideoResult) {
        self.init()
        self.id = id
        self.status = model.status
        self.video_url = model.video_url
    }
    
    func convertToDTO() -> VideoResult {
        return VideoResult(status: self.status, video_url: self.video_url)
    }
}
