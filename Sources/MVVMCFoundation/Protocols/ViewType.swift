//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 14.07.2025.
//

import Foundation

public protocol ViewType {
    associatedtype ViewModel: ViewModelType
    var viewModel: ViewModel { get }
    @MainActor func bindViewModel()
}
