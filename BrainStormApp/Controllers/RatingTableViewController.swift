//
//  RatingTableViewController.swift
//  BrainStorm
//
//  Created by Hristiyan Zahariev on 10.10.18.
//

import UIKit
import Cosmos

class RatingTableViewController: UITableViewController {

    private enum Constant {
        static let defaultRating: Double = 5
    }

    var timeToMarketScore: Int = Constant.defaultRating {
        didSet {
            setRating(for: timeToMarketCosmosView, and: timeToMarketLabel, with: timeToMarketScore)
        }
    }
    var requiredMoneyScore: Int = Constant.defaultRating {
        didSet {
            setRating(for: requiredMoneyCosmosView, and: requiredMoneyLabel, with: requiredMoneyScore)
        }
    }
    var expectedProfitScore: Int = Constant.defaultRating {
        didSet {
            setRating(for: profitCosmosView, and: expectedProfitLabel, with: expectedProfitScore)
        }
    }
    var difficultyScore: Int = Constant.defaultRating {
        didSet {
            setRating(for: difficultyCosmosView, and: difficultyLabel, with: difficultyScore)
        }
    }

    @IBOutlet weak var timeToMarketLabel: UILabel!
    @IBOutlet weak var requiredMoneyLabel: UILabel!
    @IBOutlet weak var expectedProfitLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!

    @IBOutlet weak var timeToMarketCosmosView: CosmosView! {
        didSet {
            timeToMarketCosmosView.rating = Double(timeToMarketScore)
        }
    }

    @IBOutlet weak var requiredMoneyCosmosView: CosmosView! {
        didSet {
            requiredMoneyCosmosView.rating = Double(requiredMoneyScore)
        }
    }

    @IBOutlet weak var profitCosmosView: CosmosView! {
        didSet {
            profitCosmosView.rating = Double(expectedProfitScore)
        }
    }

    @IBOutlet weak var difficultyCosmosView: CosmosView! {
        didSet {
            difficultyCosmosView.rating = Double(difficultyScore)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRatings()
    }

    // MARK: - Private

    private func setRating(for ratingView: CosmosView) {
        switch ratingView {
        case timeToMarketCosmosView:
            timeToMarketScore = Int(ratingView.rating)
        case requiredMoneyCosmosView:
            requiredMoneyScore = Int(ratingView.rating)
        case profitCosmosView:
            expectedProfitScore = Int(ratingView.rating)
        case difficultyCosmosView:
            difficultyScore = Int(ratingView.rating)
        default: return
        }
    }

    private func setRating(for ratingView: CosmosView, and label: UILabel, with value: Int) {
        ratingView.rating = Double(value)
        label.text = "\(value)"
    }

    private func setupRatings() {
        func updateRating(ratingView: CosmosView, ratingLabel: UILabel) {
            let updateRating: (Double) -> Void = { [weak self] (rating) in
                ratingView.rating = rating.rounded(.up)
                ratingLabel.text = String(Int(rating.rounded(.up)))
                self?.setRating(for: ratingView)
            }
            ratingView.didTouchCosmos = updateRating
        }

        updateRating(ratingView: timeToMarketCosmosView, ratingLabel: timeToMarketLabel)
        updateRating(ratingView: requiredMoneyCosmosView, ratingLabel: requiredMoneyLabel)
        updateRating(ratingView: profitCosmosView, ratingLabel: expectedProfitLabel)
        updateRating(ratingView: difficultyCosmosView, ratingLabel: difficultyLabel)
    }
}



