//
//  AddIdeaViewController
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 22.07.18.
//

import UIKit
import ActionSheetPicker_3_0
import Cosmos
import KMPlaceholderTextView

class AddIdeaViewController: UIViewController {
    
    private enum Constant {
        static let defaultRating: Double = 5
    }
    
    @IBOutlet weak var categoryButton: UIButton!
    
    private var selectedCategory: Category? {
        didSet {
            guard let selectedCategory = selectedCategory else {
                return
            }
            categoryButton.titleLabel?.text = selectedCategory.title
        }
    }
    
    @IBOutlet weak var timeToMarketLabel: UILabel!
    @IBOutlet weak var requiredMoneyLabel: UILabel!
    @IBOutlet weak var expectedProfitLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    
    @IBOutlet weak var timeToMarketCosmosView: CosmosView! {
        didSet {
            timeToMarketCosmosView.rating = Constant.defaultRating
        }
    }
    
    @IBOutlet weak var requiredMoneyCosmosView: CosmosView! {
        didSet {
            requiredMoneyCosmosView.rating = Constant.defaultRating
        }
    }
    
    @IBOutlet weak var profitCosmosView: CosmosView! {
        didSet {
            profitCosmosView.rating = Constant.defaultRating
        }
    }
    
    @IBOutlet weak var difficultyCosmosView: CosmosView! {
        didSet {
            difficultyCosmosView.rating = Constant.defaultRating
        }
    }
    
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView! {
        didSet {
            descriptionTextView.textContainer.maximumNumberOfLines = 5
        }
    }
    
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRatings()
    }
    
    
    // MARK: - Private
    
    private func setupRatings() {
        let updateRating: (Double) -> Void = { [weak self] (rating) in
            self?.timeToMarketCosmosView.rating = rating.rounded(.up)
            self?.timeToMarketLabel.text = String(Int(rating.rounded(.up)))
        }
        
        timeToMarketCosmosView?.didTouchCosmos = updateRating
        
        requiredMoneyCosmosView?.didTouchCosmos = updateRating
        
        profitCosmosView?.didTouchCosmos = updateRating
        
        difficultyCosmosView?.didTouchCosmos = updateRating
    }
    
    private func calculateScore(timeToMarket: Int, requiredMoney: Int, expectableProfit: Int, difficulty: Int) -> Double {
        let timeToMarketNormalizedScore = 2.0 / Double(timeToMarket)
        let requiredMoneyNormalizedScore = 3.0 / Double(requiredMoney)
        let expectableProfitNormalizedScore = Double(expectableProfit) / 5.0
        let difficultyNormalizedScore = 3.0 / Double(difficulty)
        let score = timeToMarketNormalizedScore + requiredMoneyNormalizedScore + expectableProfitNormalizedScore + difficultyNormalizedScore
        let scoreRounded = round(score / 0.1) * 0.1
        return scoreRounded
    }
    
    @IBAction func selectCategory(_ sender: UIButton) {
        UIHelper.showCategoryAction(from: self) { [weak self] category in
            guard let category = category else {
                return
            }
            self?.selectedCategory = category
        }
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        guard let title = titleTextField.text, !title.isEmpty else {
            UIHelper.showErrorAlert(with: "Enter title please")
            return
        }
        
        guard let description = descriptionTextView.text, !description.isEmpty else {
            UIHelper.showErrorAlert(with: "Enter description please")
            return
        }
        
        let rating = calculateScore(timeToMarket: Int(timeToMarketCosmosView.rating),
                                    requiredMoney: Int(requiredMoneyCosmosView.rating),
                                    expectableProfit: Int(profitCosmosView.rating),
                                    difficulty: Int(difficultyCosmosView.rating))
        
        DatabaseManager.addIdea(name: title,
                                description: description,
                                timeToMarket: Int16(timeToMarketCosmosView.rating),
                                requiredMoney: Int16(requiredMoneyCosmosView.rating),
                                expectedProfit: Int16(profitCosmosView.rating),
                                difficulty: Int16(difficultyCosmosView.rating),
                                rating: rating,
                                category: selectedCategory)
        
        navigationController?.popViewController(animated: true)
    }
}
