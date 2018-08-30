//
//  Idea.swift
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 1.08.18.
//

import Foundation
import CoreData

extension NSManagedObject {
    func randomInt64() -> Int64 {
        var t = Int64()
        arc4random_buf(&t, MemoryLayout<Int64>.size)
        return t
    }
}

@objc(Idea)
class Idea: NSManagedObject {

    @NSManaged var id: Int64
    @NSManaged var title: String
    @NSManaged var desc: String
    @NSManaged var timeToMarket: Int16
    @NSManaged var requiredMoney: Int16
    @NSManaged var expectedProfit: Int16
    @NSManaged var difficulty: Int16
    @NSManaged var score: Double
    @NSManaged var category: Category?
    
    
    func getIdeaAsString() -> String {
        var ideaTxt = ""
        ideaTxt += "Title: \(title) \n"
        if let categoryUnwrapped = category {
            ideaTxt += "Category: \(categoryUnwrapped) \n"
        } else {
            ideaTxt += "Category: none \n"
        }
        ideaTxt += "Description: \(desc) \n"
        ideaTxt += "Time to market: \(timeToMarket) \n"
        ideaTxt += "Required money: \(requiredMoney) \n"
        ideaTxt += "Expected profit: \(expectedProfit) \n"
        ideaTxt += "Difficulty: \(difficulty) \n"
        ideaTxt += "Score: \(score) \n"
        return ideaTxt
    }
}
