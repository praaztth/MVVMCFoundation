//
//  VideoModel.swift
//  MVVMCFoundation
//
//  Created by катенька on 21.10.2025.
//

import Foundation

public struct VideoModel {
    public let id: String
    public let url: URL
    
    public init(id: String, url: URL) {
        self.id = id
        self.url = url
    }
}
