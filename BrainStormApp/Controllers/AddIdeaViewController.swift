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
    
    @IBOutlet weak var timeToMarketCosmosView: CosmosView!
    @IBOutlet weak var requiredMoneyCosmosView: CosmosView!
    @IBOutlet weak var profitCosmosView: CosmosView!
    @IBOutlet weak var difficultyCosmosView: CosmosView!
    
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView! {
        didSet {
            descriptionTextView.textContainer.maximumNumberOfLines = 5
        }
    }
    
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeToMarketCosmosView.rating = 5
        requiredMoneyCosmosView.rating = 5
        profitCosmosView.rating = 5
        difficultyCosmosView.rating = 5
        
        timeToMarketCosmosView?.didTouchCosmos =
            {(rating:Double)->() in
                self.timeToMarketCosmosView.rating = rating.rounded(.up)
                self.timeToMarketLabel.text = String(Int(rating.rounded(.up)))}
        
        requiredMoneyCosmosView?.didTouchCosmos =
            {(rating:Double)->() in
                self.requiredMoneyCosmosView.rating = rating.rounded(.up)
                self.requiredMoneyLabel.text = String(Int(rating.rounded(.up)))}
        
        profitCosmosView?.didTouchCosmos =
            {(rating:Double)->() in
                self.profitCosmosView.rating = rating.rounded(.up)
                self.expectedProfitLabel.text = String(Int(rating.rounded(.up)))}
        
        difficultyCosmosView?.didTouchCosmos =
            {(rating:Double)->() in
                self.difficultyCosmosView.rating = rating.rounded(.up)
                self.difficultyLabel.text = String(Int(rating.rounded(.up)))}
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
