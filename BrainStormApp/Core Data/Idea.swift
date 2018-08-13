//
//  Idea.swift
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 1.08.18.
//

import Foundation
import CoreData

@objc(Idea)
class Idea: NSManagedObject {
    
    @NSManaged var title: String
    @NSManaged var desc: String
    @NSManaged var score: Double
    @NSManaged var category: Category?
}
