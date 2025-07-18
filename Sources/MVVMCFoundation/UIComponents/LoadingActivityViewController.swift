//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 18.07.2025.
//

import UIKit
import SnapKit

public class LoadingActivityViewController: UIViewController {
    let activity = UIActivityIndicatorView(style: .large)
    
    let activityView = UIView()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActivityIndicator()
        setupActivityView()
        
        activityView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        activity.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activity.startAnimating()
    }
    
    func setupActivityIndicator() {
        activityView.addSubview(activity)
        activity.hidesWhenStopped = true
    }
    
    func setupActivityView() {
        view.addSubview(activityView)
        activityView.layer.cornerRadius = 10
        activityView.backgroundColor = .white.withAlphaComponent(0.5)
    }
}
