//
//  DatabaseManager.swift
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 1.08.18.
//

import Foundation
import UIKit
import CoreStore

class DatabaseManager {
    
    static func addCategory(_ name: String, color: UIColor, colorName: String, icon: UIImage) -> Void {
        
        CoreStore.perform(
            asynchronous: { (transaction) -> Void in
                let category = transaction.create(Into<Category>())
                category.title = name
                
                
                category.color = color
                category.icon = icon
                category.colorTitle = colorName
                
        },
            completion: { (result) -> Void in
                switch result {
                case .success: print("Catrgory added")
                case .failure(let error): print(error)
                }
        })
    }
    
    static func delete(category: Category) {
        CoreStore.perform(
            asynchronous: { (transaction) -> Void in
                transaction.delete(category)
        },
            completion: { _ in }
        )
    }
    
    static func delete(idea: Idea) {
        CoreStore.perform(
            asynchronous: { (transaction) -> Void in
                transaction.delete(idea)
        },
            completion: { _ in }
        )
    }
    
    static func categories() -> [Category] {
        return CoreStore.fetchAll(From<Category>())!
    }
    
    static func addIdea(name: String, description: String, rating: Double, category: Category?) -> Void {
        CoreStore.perform(
            asynchronous: { (transaction) -> Void in
                let idea = transaction.create(Into<Idea>())
                idea.title = name
                idea.desc = description
                idea.score = rating
                
                guard let category = category else {
                    return
                }
                let fetchedCategory = transaction.fetchExisting(category)!
                idea.category = fetchedCategory
        },
            completion: { (result) -> Void in
                switch result {
                case .success: print("Idea added")
                case .failure(let error): print(error)
                }
        })
    }
}
