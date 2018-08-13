//
//  CustomNavigationController.swift
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 18.07.18.
//

import Foundation
import UIKit

class CustomNavigationControllerWithGradient: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureNavigationBar()
    }
    
    // MARK: - Private
    
    private func configureNavigationBar() {
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        navigationBar.contentMode = .top
    }
}

extension CustomNavigationControllerWithGradient: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let barButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = barButtonItem
    }
}
