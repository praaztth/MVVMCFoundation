//
//  GenerationService.swift
//  MVVMCFoundation
//
//  Created by катенька on 11.09.2025.
//


import Foundation
import PixVerseAPI
import Combine
import RealmSwift
import MVVMCFoundation
import Alamofire

public final class GenerationService {
    nonisolated(unsafe) public static let shared = GenerationService()
    
//    let statusPublisher = PassthroughSubject<Result<String?, Error>, Never>()
    
    private var statusTimers: [String: DispatchSourceTimer] = [:]
    private let api = PixVerseAPI.shared
    
    private init() {}
    
    public func handlePhotoResult(_ result: Result<PhotoResult, AFError>, callback: @escaping (Result<(URL, String), PixVerseError>) -> Void) {
        switch result {
        case .success(let photoResult):
            guard let url = URL(string: photoResult.url) else {
                callback(.failure(PixVerseError.generationError(detail: "No photo available")))
                return
            }
            
            let photoID = try? GenerationService.shared.savePhoto(photoResult)
            callback(.success((url, photoID ?? "")))
            
        case .failure(let error):
            checkError(error: error) { pixVerseError in
                callback(.failure(pixVerseError))
            }
        }
    }
    
    public func handleVideoResult(_ result: Result<VideoGenerationTask, AFError>, callback: @escaping (Result<URL, PixVerseError>) -> Void) {
        switch result {
        case .success(let task):
            let taskID = task.video_id
            try? GenerationService.shared.saveGenerationTask(task)
            
            startCheckingStatus(for: String(taskID)) { [unowned self] result in
                switch result {
                case .success(let videoResult):
                    guard let url = URL(string: videoResult.video_url ?? "") else {
                        callback(.failure(PixVerseError.generationError(detail: "No video available")))
                        return
                    }
                    
                    callback(.success(url))
                    
                case .failure(let failure):
                    checkError(error: failure) { pixVerseError in
                        callback(.failure(pixVerseError))
                    }
                }
                
                
            }
            
        case .failure(let error):
            checkError(error: error) { pixVerseError in
                callback(.failure(pixVerseError))
            }
        }
    }
    
    public func checkError(error: Error, callback: (PixVerseError) -> Void) {
        guard let error = error as? AFError else {
            callback(PixVerseError.generationError(detail: error.localizedDescription))
            return
        }
        
        switch error {
        case .responseValidationFailed(let reason):
            if case let .customValidationFailed(customError) = reason,
               let apiError = customError as? PixVerseError {
                callback(apiError)
                return
            }
            
        case .sessionTaskFailed(let reason):
            if let urlError = reason as? URLError,
               urlError.code == .timedOut {
                callback(PixVerseError.generationError(detail: "Request timed out"))
                return
            }
            
        default:
            callback(PixVerseError.generationError(detail: error.localizedDescription))
            return
        }
    }
    
    public func startCheckingStatus(for taskId: String, callback: @escaping (Result<VideoResult, Error>) -> Void) {
        let queue = DispatchQueue.global(qos: .utility)
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: 5.0)

        timer.setEventHandler { [unowned self] in
            self.api.checkStatus(requestID: taskId) { result in
                do {
                    let videoResult = try result.get()
                    try GenerationService.shared.saveVideo(videoResult, id: taskId)
                    
                    if videoResult.status == "success" {
                        callback(.success(videoResult))
                        self.stopCheckingStatus(for: taskId)
                    }
                    
                } catch {
                    callback(.failure(error))
                    self.stopCheckingStatus(for: taskId)
                    print(error)
                }
            }
        }

        timer.resume()
        statusTimers[taskId] = timer
    }
    
    public func stopCheckingStatus(for taskId: String) {
        statusTimers[taskId]?.cancel()
        statusTimers[taskId] = nil
    }
    
    public func continueIncompletedGenerationTasks() {
        do {
            let realm = try Realm()
            let objects = realm.objects(VideoGenerationTaskObject.self)
            let tasks = objects.map { VideoGenerationTask(video_id: $0.video_id, detail: $0.detail) }
            
            tasks.forEach { task in
                startCheckingStatus(for: String(task.video_id)) { _ in }
            }
        } catch {
            print(error)
        }
    }
    
    
//    public func handleVideoByTemplate(
//        api: PixVerseAPIProtocol,
//        userID: String,
//        bundleID: String,
//        imageData: Data,
//        imageName: String,
//        templateID: String
//    ) -> Observable<VideoModel> {
//        let videoResult = api.generateVideo(byTemplateID: templateID, usingImage: imageData, imageName: imageName, userID: userID, appBundle: bundleID)
//            .do(onError: { error in print(error) })
//            .flatMap { [unowned self] task in
//                try self.saveGenerationTask(task)
//                return try self.handleVideoGeneration(task: task, api: api)
//            }
//        
//        let subject = getPublishSubjectFromObservable(videoResult)
//        return subject.asObservable()
//    }
//    
//    public func handleVideoByPrompt(
//        api: PixVerseAPIProtocol,
//        userID: String,
//        bundleID: String,
//        prompt: String
//    ) -> Observable<VideoModel> {
//        let videoResult = api.generateVideo(from: prompt, userID: userID, appBundle: bundleID)
//            .flatMap { [unowned self] task in
//                try self.saveGenerationTask(task)
//                return try self.handleVideoGeneration(task: task, api: api)
//            }
//        
//        let subject = getPublishSubjectFromObservable(videoResult)
//        return subject.asObservable()
//    }
//    
//    public func handleVideoByPromptImage(
//        api: PixVerseAPIProtocol,
//        userID: String,
//        bundleID: String,
//        prompt: String,
//        imageData: Data,
//        imageName: String
//    ) -> Observable<VideoModel> {
//        let videoResult = api.generateVideo(from: prompt, usingImage: imageData, imageName: imageName, userID: userID, appBundle: bundleID)
//            .flatMap { [unowned self] task in
//                try self.saveGenerationTask(task)
//                return try self.handleVideoGeneration(task: task, api: api)
//            }
//        
//        let subject = getPublishSubjectFromObservable(videoResult)
//        return subject.asObservable()
//    }
//    
//    public func hangleVideoByStyleVideo(
//        api: PixVerseAPIProtocol,
//        userID: String,
//        bundleID: String,
//        videoUrl: URL,
//        videoName: String,
//        styleID: String
//    ) -> Observable<VideoModel> {
//        let videoResult = api.generateVideo(usingVideo: videoUrl, videoName: videoName, byStyleID: styleID, userID: userID, appBundle: bundleID)
//            .flatMap { [unowned self] task in
//                try self.saveGenerationTask(task)
//                return try self.handleVideoGeneration(task: task, api: api)
//            }
//        
//        let subject = getPublishSubjectFromObservable(videoResult)
//        return subject.asObservable()
//    }
//    
//    public func handleTransitionVideo(
//        api: PixVerseAPIProtocol,
//        userID: String,
//        bundleID: String,
//        firstImageData: Data,
//        firstImageName: String,
//        secondImageData: Data, secondImageName: String, prompt: String) -> Observable<VideoModel> {
//        let videoResult = api.generateTransitionVideo(firstImageData: firstImageData, firstImageName: firstImageName, secondImageData: secondImageData, secondImageName: secondImageName, prompt: prompt, userID: userID, appBundle: bundleID)
//            .flatMap { [unowned self] task in
//                try self.saveGenerationTask(task)
//                return try self.handleVideoGeneration(task: task, api: api)
//            }
//        
//        let subject = getPublishSubjectFromObservable(videoResult)
//        return subject.asObservable()
//    }
//    
//    public func handleVideoContinuation(api: PixVerseAPIProtocol, userID: String, bundleID: String, videoUrl: URL, prompt: String) -> Observable<VideoModel> {
//        let videoResult = api.generateVideoСontinuation(usingVideo: videoUrl, prompt: prompt, userID: userID, appBundle: bundleID)
//            .flatMap { [unowned self] task in
//                try self.saveGenerationTask(task)
//                return try self.handleVideoGeneration(task: task, api: api)
//            }
//        
//        let subject = getPublishSubjectFromObservable(videoResult)
//        return subject.asObservable()
//    }
//    
//    public func handlePhotoByTemplate(api: PixVerseAPIProtocol, userID: String, bundleID: String, imageData: Data, imageName: String, templateID: String) -> Observable<PhotoResult> {
//        let photoResult = api.generatePhoto(byTemplateID: templateID, usingImage: imageData, imageName: imageName, userID: userID, appBundle: bundleID)
//            .do(onNext: { [unowned self] in try self.savePhoto($0) })
//        
//        let subject = getPublishSubjectFromObservable(photoResult)
//        return subject.asObservable()
//    }
//    
//    public func handlePhotoByPrompt(api: PixVerseAPIProtocol, userID: String, bundleID: String, prompt: String) -> Observable<PhotoResult> {
//        let photoResult = api.generatePhoto(from: prompt, userID: userID, appBundle: bundleID)
//            .do(onNext: { [unowned self] in try self.savePhoto($0) })
//        
//        let subject = getPublishSubjectFromObservable(photoResult)
//        return subject.asObservable()
//            
//    }
//    
//    public func handlePhotoByPromptImage(api: PixVerseAPIProtocol, userID: String, bundleID: String, prompt: String, imageData: Data, imageName: String) -> Observable<PhotoResult> {
//        let photoResult = api.generatePhoto(from: prompt, usingImage: imageData, imageName: imageName, userID: userID, appBundle: bundleID)
//            .do(onNext: { [unowned self] in try self.savePhoto($0) })
//        
//        let subject = getPublishSubjectFromObservable(photoResult)
//        return subject.asObservable()
//    }
//    
//    public func handleVideoGeneration(task: VideoGenerationTask, api: PixVerseAPIProtocol) throws -> Observable<VideoModel> {
//            let videoID = String(task.video_id)
//        
//            return api.handleVideoGenerationStatus(videoID: videoID)
//                .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
//                .do(onNext: { [unowned self] videoID, videoResult in
//                    try self.saveVideo(videoResult, id: videoID)
//                }, onError: {
//                    print($0)
//                })
//                .filter { videoID, video in
//                    video.status == "success" || video.status == "error"
//                }
//                .take(1)
//                .do(onNext: { [unowned self] videoID, _ in
//                    try self.removeGenerationTask(with: videoID)
//                })
//                .compactMap { videoID, video -> VideoModel? in
//                    guard let urlString = video.video_url,
//                          let url = URL(string: urlString) else {
//                        print("\(#fileID): \(#function): no video url")
//                        return nil
//                    }
//                    return VideoModel(id: videoID, url: url)
//                }
//    }
    
    
    
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
    
    public func savePhoto(_ photo: PhotoResult) throws -> String {
        let photoID = UUID().uuidString
        
        let realm = try Realm()
        try realm.write {
            let object = PhotoResultObject(id: photoID, url: photo.url, detail: photo.detail)
            realm.add(object, update: .modified)
        }
        
        return photoID
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
