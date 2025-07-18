//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 15.07.2025.
//

import Foundation

public protocol CoordinatorHierarchy: AnyObject {
    var parentCoordinator: CoordinatorHierarchy? { get set }
    var childCoordinators: [CoordinatorHierarchy] { get set }
}

public extension CoordinatorHierarchy {
    func childDidFinish(_ coordinator: CoordinatorHierarchy) {
        if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
            childCoordinators.remove(at: index)
        }
    }
}
