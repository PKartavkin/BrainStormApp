//
//  IdeaTableViewCell.swift
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 4.08.18.
//

import UIKit

class IdeaTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var categoryStaticLabel: UILabel!
    
    
    // MARK: - Public
    
    func configure(with idea: Idea) {
        titleLabel.text = idea.title
        descriptionLabel.text = idea.desc
        categoryImageView.image = idea.category?.icon ?? #imageLiteral(resourceName: "white_category_icon")
        categoryTitleLabel.text = idea.category?.title
        ratingLabel.text = "\(idea.score)"
        categoryStaticLabel.isHidden = idea.category == nil
    }
}
