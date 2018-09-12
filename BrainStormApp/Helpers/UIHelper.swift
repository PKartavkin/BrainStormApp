//
//  UIHelper.swift
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 22.07.18.
//

import Foundation
import Rswift

struct CategoryImage {
    
    let image: UIImage
    let name: String
    let color: UIColor
    
    init(image: UIImage, name: String, color: UIColor) {
        self.image = image
        self.name = name
        self.color = color
    }
}

class UIHelper {
    
    private enum Const {
        static let actionImageKey = "image"
        static let actionTitleKey = "titleTextColor"
        static let colorImages: [CategoryImage] = [CategoryImage(image: #imageLiteral(resourceName: "blue_category_icon"), name: "Blue", color: .blue),
                                                   CategoryImage(image: #imageLiteral(resourceName: "green_category_icon"), name: "Green", color: .green),
                                                   CategoryImage(image: #imageLiteral(resourceName: "yellow_category_icon"), name: "Yellow", color: Color.yellow),
                                                   CategoryImage(image: #imageLiteral(resourceName: "pink_category_icon"), name: "Pink", color: Color.pink),
                                                   CategoryImage(image: #imageLiteral(resourceName: "red_category_icon"), name: "Red", color: .red),
                                                   CategoryImage(image: #imageLiteral(resourceName: "light_blue_category_icon"), name: "Light Blue", color: Color.lightBlue),
                                                   CategoryImage(image: #imageLiteral(resourceName: "orange_category_icon"), name: "Orange",color: .orange),
                                                   CategoryImage(image: #imageLiteral(resourceName: "purple_category_icon"), name: "Purple", color: Color.purple)]
    }
    
    class func showCategoryAction(from viewController: UIViewController,
                                  completionHandler: @escaping ((Category?) -> Void)) {
        
        func createAction(title: String, image: UIImage, completionHandler: @escaping (UIAlertAction) -> ()) -> UIAlertAction {
            let action = UIAlertAction(title: title, style: .default, handler: completionHandler)
            action.setValue(image, forKey: Const.actionImageKey)
            action.setValue(UIColor.black, forKey: Const.actionTitleKey)
            return action
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for category in DatabaseManager.categories() {
            let action = UIAlertAction(title: category.title, style: .default) { _ in
                completionHandler(category)
            }
            
            action.setValue(category.icon, forKey: Const.actionImageKey)
            action.setValue(category.color, forKey: Const.actionTitleKey)
            
            alert.addAction(action)
        }
        
        let noCategoryAction = UIAlertAction(title: "No category", style: .default) { _ in
            completionHandler(nil)
        }
        noCategoryAction.setValue(UIColor.black, forKey: Const.actionTitleKey)
        alert.addAction(noCategoryAction)
        
        alert.addAction(createAction(title: "Add Category", image: #imageLiteral(resourceName: "add_category_icon")) { _ in
            UIApplication.topViewController()?.performSegue(withIdentifier: R.segue.addIdeaViewController.showAddCategory.identifier, sender: nil)
            completionHandler(nil)
        })
        
        alert.addAction(createAction(title: "Manage categories", image: #imageLiteral(resourceName: "manage_category_icon")) { _ in
            UIApplication.topViewController()?.performSegue(withIdentifier: R.segue.addIdeaViewController.showManageCategories.identifier, sender: nil)
            completionHandler(nil)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(nil)
        })
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    class func showColors(from viewController: UIViewController,
                                  completionHandler: @escaping ((CategoryImage?) -> Void)) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for categoryImage in Const.colorImages {
            let action = UIAlertAction(title: categoryImage.name, style: .default) { _ in
                completionHandler(categoryImage)
            }
            
            if categoryImage.image == #imageLiteral(resourceName: "white_category_icon") {
                action.setValue(categoryImage.image, forKey: Const.actionImageKey)
            } else {
                action.setValue(categoryImage.image, forKey: Const.actionImageKey)
                action.setValue(categoryImage.color, forKey: Const.actionTitleKey)
            }
            
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(nil)
        })
        
        viewController.present(alert, animated: true, completion: nil)
    }

    static func showErrorAlert(with errorDescription: String?) {
        let message = errorDescription ?? "Something went wrong"
        showAlert(message: message, title: "Oops")
    }
    
    static func showGreetingAlert() {
        let message = "Thank you for downloading BrainStorm app! We believe it helps you to find idea for your startup. Don't give up, keep moving forward and be afraid of procrastination."
        showAlert(message: message, title: "Greetings!")
    }

    static func showExportAlert(with ideasCount: Int) {
        let message = "Exported \(ideasCount) ideas to clipboard"
        showAlert(message: message, title: "Success!")
    }
    
    private static func showAlert(message: String, title: String) {
        let alertController = UIAlertController(title: title,
                                                message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        let topViewController = UIApplication.topViewController()
        topViewController?.present(alertController, animated: true, completion: nil)
    }
    
}

extension UIApplication {
    class func topViewController(base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

