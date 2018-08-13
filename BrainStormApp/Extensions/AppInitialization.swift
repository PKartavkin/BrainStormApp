//
//  AppInitialization.swift
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 18.07.18.
//

import Foundation
import UIKit
import CoreStore

extension AppDelegate {
    func setupAppereance() {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: Font.navigationBarTitle,
                                                            NSAttributedStringKey.foregroundColor: Color.navigationBarTitleColor]
    }
    
    func setupCoreStore() {
        do {
            try CoreStore.addStorageAndWait()
        } catch {
            
        }
    }
    
    func presetupCategories() {
        if DatabaseManager.categories().isEmpty {
            DatabaseManager.addCategory("Media", color: .blue, colorName: "Blue", icon: #imageLiteral(resourceName: "blue_category_icon"))
            DatabaseManager.addCategory("Dropshipping", color: .green, colorName: "Green", icon: #imageLiteral(resourceName: "green_category_icon"))
            DatabaseManager.addCategory("Mobile Games", color: .orange, colorName: "Orange", icon: #imageLiteral(resourceName: "orange_category_icon"))
            DatabaseManager.addCategory("Manufacturing", color: Color.yellow, colorName: "Yellow", icon: #imageLiteral(resourceName: "yellow_category_icon"))
        }
    }
}
