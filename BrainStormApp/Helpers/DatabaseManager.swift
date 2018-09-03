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
                category.id = category.randomInt64()
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
    
    static func addIdea(name: String,
                        description: String,
                        timeToMarket: Int16,
                        requiredMoney: Int16,
                        expectedProfit: Int16,
                        difficulty: Int16,
                        rating: Double,
                        category: Category?) -> Void {

        CoreStore.perform(
            asynchronous: { (transaction) -> Void in
                let idea = transaction.create(Into<Idea>())
                idea.id = idea.randomInt64()
                idea.title = name
                idea.desc = description
                idea.timeToMarket = timeToMarket
                idea.requiredMoney = requiredMoney
                idea.expectedProfit = expectedProfit
                idea.difficulty = difficulty
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

    static func edit(idea: Idea) -> Void {
        CoreStore.perform(
            asynchronous: { (transaction) -> Void in
                guard let currentIdea = transaction.fetchOne(From<Idea>().where(\.id == idea.id)) else {
                    return
                }

                currentIdea.title = idea.title
                if let currentCategory = idea.category {
                    currentIdea.category = transaction.fetchExisting(currentCategory)
                }
                currentIdea.desc = idea.desc
                currentIdea.timeToMarket = idea.timeToMarket
                currentIdea.expectedProfit = idea.expectedProfit
                currentIdea.requiredMoney = idea.requiredMoney
                currentIdea.difficulty = idea.difficulty
        },
            completion: { (result) -> Void in
                switch result {
                case .success: print("Idea edited")
                case .failure(let error): print(error)
                }
        })
    }

    static func edit(category: Category) -> Void {
        CoreStore.perform(
            asynchronous: { (transaction) -> Void in
                guard let currentCategory = transaction.fetchOne(From<Category>().where(\.id == category.id)) else {
                    return
                }

                currentCategory.color = category.color
                currentCategory.colorTitle = category.colorTitle
                currentCategory.icon = category.icon
                currentCategory.title = category.title
        },
            completion: { (result) -> Void in
                switch result {
                case .success: print("Idea edited")
                case .failure(let error): print(error)
                }
        })
    }
}
