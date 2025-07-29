//
//  VideoGenerationTaskObjectt.swift
//  MVVMCFoundation
//
//  Created by катенька on 29.07.2025.
//


import RealmSwift
import PixVerseAPI

final class VideoGenerationTaskObject: Object {
    @Persisted(primaryKey: true) var video_id: Int
    @Persisted var detail: String
    
    convenience init(videoID: Int, detail: String) {
        self.init()
        self.video_id = videoID
        self.detail = detail
    }
    
    convenience init(from model: VideoGenerationTask) {
        self.init()
        self.video_id = model.video_id
        self.detail = model.detail
    }
    
    func convertToDTO() -> VideoGenerationTask {
        return VideoGenerationTask(video_id: self.video_id, detail: self.detail)
    }
}
