//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 11.09.2025.
//

import UIKit

public extension UIViewController {
    public func presentMessage(title: String? = nil, message: String, callback: (() -> Void)? = nil) {
        let alertControllerr = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .default) { _ in
            callback?()
        }
        alertControllerr.addAction(okayAction)
        present(alertControllerr, animated: true)
    }
    
    public func removeFromNavigationStack(viewController: UIViewController) {
       if let index = self.navigationController?.viewControllers.firstIndex(where: { $0 == self }) {
           self.navigationController?.viewControllers.remove(at: index)
       }
   }
}
