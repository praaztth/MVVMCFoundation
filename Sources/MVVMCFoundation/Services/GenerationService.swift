//
//  GenerationService.swift
//  MVVMCFoundation
//
//  Created by катенька on 11.09.2025.
//


import Foundation
import PixVerseAPI
import RxSwift
import RealmSwift
import MVVMCFoundation

public final class GenerationService {
    nonisolated(unsafe) public static let shared = GenerationService()
    
    private let disposeBag = DisposeBag()
    
    private init() {}
    
    public func handleVideoByTemplate(api: PixVerseAPIProtocol, userID: String, bundleID: String, imageData: Data, imageName: String, templateID: String) -> Observable<VideoResult> {
        let videoResult = api.generateVideo(byTemplateID: templateID, usingImage: imageData, imageName: imageName, userID: userID, appBundle: bundleID)
            .do(onError: { error in print(error) })
            .flatMap { [unowned self] task in
                try self.saveGenerationTask(task)
                return try self.handleVideoGeneration(task: task, api: api)
            }
        
        let subject = getPublishSubjectFromObservable(videoResult)
        return subject.asObservable()
    }
    
    public func handleVideoByPrompt(api: PixVerseAPIProtocol, userID: String, bundleID: String, prompt: String) -> Observable<VideoResult> {
        let videoResult = api.generateVideo(from: prompt, userID: userID, appBundle: bundleID)
            .flatMap { [unowned self] task in
                try self.saveGenerationTask(task)
                return try self.handleVideoGeneration(task: task, api: api)
            }
        
        let subject = getPublishSubjectFromObservable(videoResult)
        return subject.asObservable()
    }
    
    public func handleVideoByPromptImage(api: PixVerseAPIProtocol, userID: String, bundleID: String, prompt: String, imageData: Data, imageName: String) -> Observable<VideoResult> {
        let videoResult = api.generateVideo(from: prompt, usingImage: imageData, imageName: imageName, userID: userID, appBundle: bundleID)
            .flatMap { [unowned self] task in
                try self.saveGenerationTask(task)
                return try self.handleVideoGeneration(task: task, api: api)
            }
        
        let subject = getPublishSubjectFromObservable(videoResult)
        return subject.asObservable()
    }
    
    public func hangleVideoByStyleVideo(api: PixVerseAPIProtocol, userID: String, bundleID: String, videoUrl: URL, videoName: String, styleID: String) -> Observable<VideoResult> {
        let videoResult = api.generateVideo(usingVideo: videoUrl, videoName: videoName, byStyleID: styleID, userID: userID, appBundle: bundleID)
            .flatMap { [unowned self] task in
                try self.saveGenerationTask(task)
                return try self.handleVideoGeneration(task: task, api: api)
            }
        
        let subject = getPublishSubjectFromObservable(videoResult)
        return subject.asObservable()
    }
    
    public func handlePhotoByTemplate(api: PixVerseAPIProtocol, userID: String, bundleID: String, imageData: Data, imageName: String, templateID: String) -> Observable<PhotoResult> {
        let photoResult = api.generatePhoto(byTemplateID: templateID, usingImage: imageData, imageName: imageName, userID: userID, appBundle: bundleID)
            .do(onNext: { [unowned self] in try self.savePhoto($0) })
        
        let subject = getPublishSubjectFromObservable(photoResult)
        return subject.asObservable()
    }
    
    public func handlePhotoByPrompt(api: PixVerseAPIProtocol, userID: String, bundleID: String, prompt: String) -> Observable<PhotoResult> {
        let photoResult = api.generatePhoto(from: prompt, userID: userID, appBundle: bundleID)
            .do(onNext: { [unowned self] in try self.savePhoto($0) })
        
        let subject = getPublishSubjectFromObservable(photoResult)
        return subject.asObservable()
            
    }
    
    public func handlePhotoByPromptImage(api: PixVerseAPIProtocol, userID: String, bundleID: String, prompt: String, imageData: Data, imageName: String) -> Observable<PhotoResult> {
        let photoResult = api.generatePhoto(from: prompt, usingImage: imageData, imageName: imageName, userID: userID, appBundle: bundleID)
            .do(onNext: { [unowned self] in try self.savePhoto($0) })
        
        let subject = getPublishSubjectFromObservable(photoResult)
        return subject.asObservable()
    }
    
    public func handleVideoGeneration(task: VideoGenerationTask, api: PixVerseAPIProtocol) throws -> Observable<VideoResult> {
            let videoID = String(task.video_id)
        
            return api.handleVideoGenerationStatus(videoID: videoID)
                .do(onNext: { [unowned self] videoID, videoResult in
                    try self.saveVideo(videoResult, id: videoID)
                }, onError: {
                    print($0)
                })
                .filter { videoID, video in
                    video.status == "success" || video.status == "error"
                }
                .take(1)
                .do(onNext: { [unowned self] videoID, _ in
                    try self.removeGenerationTask(with: videoID)
                })
                .map { _, video in return video }
    }
    
    private func getPublishSubjectFromObservable<T>(_ observable: Observable<T>) -> PublishSubject<T> {
        let subject = PublishSubject<T>()
        
        observable
            .subscribe(onNext: { item in
                subject.onNext(item)
            }, onError: {
                subject.onError($0)
            })
            .disposed(by: disposeBag)
        
        return subject
    }
    
    public func disposedByServiceBag(disposable: Disposable) {
        disposable.disposed(by: disposeBag)
    }
    
    public func saveGenerationTask(_ task: VideoGenerationTask) throws {
        let realm = try Realm()
        try realm.write {
            let taskObject = VideoGenerationTaskObject(videoID: task.video_id, detail: task.detail)
            realm.add(taskObject)
        }
    }
    
    public func saveVideo(_ video: VideoResult, id: String) throws {
        guard let id = Int(id) else { return }
        let realm = try Realm()
        try realm.write {
            let object = VideoResultObject(id: id, status: video.status, video_url: video.video_url)
            realm.add(object, update: .modified)
        }
        print(video.status)
    }
    
    public func savePhoto(_ photo: PhotoResult) throws {
        let realm = try Realm()
        try realm.write {
            let object = PhotoResultObject(id: UUID().uuidString, url: photo.url, detail: photo.detail)
            realm.add(object, update: .modified)
        }
    }
    
    public func removeGenerationTask(with id: String) throws {
        guard let id = Int(id) else { return }
        let realm = try Realm()
        try realm.write {
            if let object = realm.object(ofType: VideoGenerationTaskObject.self, forPrimaryKey: id) {
                realm.delete(object)
            }
        }
    }
}
