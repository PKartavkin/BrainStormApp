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
}
