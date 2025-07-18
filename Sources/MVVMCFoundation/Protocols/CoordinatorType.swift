//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 14.07.2025.
//

import Foundation
import UIKit

public protocol CoordinatorType: CoordinatorHierarchy {
    associatedtype Screen
    associatedtype View: UIViewController
    
    var viewController: View? { get }
    
    func start() -> View
    @MainActor func routeTo(_ screen: Screen)
}

public extension CoordinatorType {
    @MainActor func showAlert(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        viewController?.present(alertController, animated: true)
    }
    
    @MainActor func removeFromNavigationStack(viewController: UIViewController) {
       if let index = self.viewController?.navigationController?.viewControllers.firstIndex(where: { $0 == viewController }) {
           self.viewController?.navigationController?.viewControllers.remove(at: index)
       }
   }
}
