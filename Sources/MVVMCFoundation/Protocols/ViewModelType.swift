//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 14.07.2025.
//

import Foundation

public protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    associatedtype Coordinator: CoordinatorType
    
    var coordinator: Coordinator { get }
    
    func transform(_ input: Input) -> Output
}
