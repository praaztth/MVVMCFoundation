//
//  VideoGenerationTaskObjectt.swift
//  MVVMCFoundation
//
//  Created by катенька on 29.07.2025.
//


import RealmSwift

final public class VideoGenerationTaskObject: Object {
    @Persisted(primaryKey: true) public var video_id: Int
    @Persisted public var detail: String
    
    public convenience init(videoID: Int, detail: String) {
        self.init()
        self.video_id = videoID
        self.detail = detail
    }
}
