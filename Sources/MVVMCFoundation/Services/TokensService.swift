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
    private let disposeBag = DisposeBag()
    
    public var isTokensAvailable: Bool {
        get { _isTokensAvailable }
    }
    
    private init() {}
    
    @MainActor
    public func refreshTokensAvailability() {
        checkTokensAvailability()
            .subscribe(onSuccess: { [unowned self] isAvailable in
                self._isTokensAvailable = isAvailable
                
            }, onFailure: { error in
                print("\(#fileID): \(#function): \(error.localizedDescription)")
                
            })
            .disposed(by: disposeBag)
    }
    
    public func fetchTokensCount() -> Observable<Int> {
        PixVerseAPI.shared.fetchTokensCount(userId: UserSessionService.shared.userID, appId: Bundle.main.bundleIdentifier ?? "")
            .map { $0.balance }
    }
    
    @MainActor
    private func checkTokensAvailability() -> Single<Bool> {
        Single.create { single in
            SwiftHelper.apphudHelper.fetchProducts(paywallID: "tokens") { products in
                for product in products {
                    guard product.skProduct != nil else {
                        single(.success(false))
                        return
                    }
                }
                
                single(.success(true))
            }
            
            return Disposables.create()
        }
    }
}
