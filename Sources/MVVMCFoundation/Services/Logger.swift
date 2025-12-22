//
//  Lojger.swift
//  MVVMCFoundation
//
//  Created by катенька on 19.12.2025.
//

import Foundation

public final class Logger {
    nonisolated(unsafe) public static let shared = Logger()
    
    public let fileURL = FileManager.default.urls(for: .documentDirectory, in: [.userDomainMask]).first?.appendingPathComponent("logs.txt")
    
    public func log(_ text: String) {
        let data = ("[\(Date().formatted())]: \(text)\n").data(using: .utf8)!
        
        guard let fileURL else { return }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let fileHandle = try? FileHandle(forWritingTo: fileURL)
            defer { fileHandle?.closeFile() }
            let _ = try? fileHandle?.seekToEnd()
            fileHandle?.write(data)
        } else {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
