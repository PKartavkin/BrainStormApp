//
//  CategoryTableViewCell.swift
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 3.08.18.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Public
    
    func configure(with category: Category) {
        iconImageView.image = category.icon
        titleLabel.text = category.title
    }

}
