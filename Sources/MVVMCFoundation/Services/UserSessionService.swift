//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 18.07.2025.
//

import Foundation

public class UserSessionService {
    nonisolated(unsafe) public static let shared = UserSessionService()
    private var _userID: String = "test"
    private var _isProEnabled: Bool = false
    
    public var userID: String { get { _userID } set { _userID = newValue } }
    
    public var isProEnabled: Bool { get { _isProEnabled } set { _isProEnabled = newValue } }
}
