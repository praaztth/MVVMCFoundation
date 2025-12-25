//
//  TokenService.swift
//  MVVMCFoundation
//
//  Created by катенька on 13.11.2025.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftHelper
import MVVMCFoundation
import PixVerseAPI

public final class TokensService {
    nonisolated(unsafe) public static let shared = TokensService()
    
    private var _isTokensAvailable: Bool = false
    
    public var isTokensAvailable: Bool {
        get { _isTokensAvailable }
    }
    
    private init() {}
    
    @MainActor
    public func refreshTokensAvailability() {
        checkTokensAvailability() { [unowned self] isAvailable in
            self._isTokensAvailable = isAvailable
        }
    }
    
    public func fetchTokensCount(callback: @escaping (Int) -> Void) {
        PixVerseAPI.shared.fetchTokensCount(userId: UserSessionService.shared.userID, appId: Bundle.main.bundleIdentifier ?? "") { result in
            do {
                let response = try result.get()
                callback(response.balance)
            } catch {
                print(error)
            }
        }
    }
    
    @MainActor
    private func checkTokensAvailability(callback: @escaping (Bool) -> Void) {
        SwiftHelper.apphudHelper.fetchProducts(paywallID: "tokens") { [unowned self] products in
            for product in products {
                guard product.skProduct != nil else {
                    callback(false)
                    return
                }
            }
            
            callback(true)
        }
    }
}
