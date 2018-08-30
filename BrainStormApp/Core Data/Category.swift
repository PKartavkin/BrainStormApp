//
//  Category.swift
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 1.08.18.
//

import Foundation
import CoreData
import UIKit

@objc(Category)
class Category: NSManagedObject {

    @NSManaged var id: Int64
    @NSManaged var title: String
    @NSManaged var color: UIColor
    @NSManaged var colorTitle: String
    @NSManaged var icon: UIImage
    
}
