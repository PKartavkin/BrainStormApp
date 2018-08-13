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
        static let ratings: [Int] = Array(1...10)
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
    
    // MARK: - Private
    
    private func showStandartPicker(fieldName: String, fieldButton: UIButton, completionHandler: ((Int) -> Void)? = nil) {
        ActionSheetStringPicker.show(withTitle: fieldName, rows: Constant.ratings, initialSelection: 0, doneBlock: { picker, index, value in
            var title = fieldName
            title = "\(value ?? title)"
            completionHandler?(Int(title)!)
            
            fieldButton.setTitle(title, for: .normal)
            
        }, cancel: {ActionStringCancelBlock in return}, origin: fieldButton)
    }
    
    private func calculateScore(timeToMarket: Int, requiredMoney: Int, expectableProfit: Int, difficulty: Int) -> Double {
        let timeToMarketNormalizedScore = Double(2 / timeToMarket)
        let requiredMoneyNormalizedScore = Double(3 / requiredMoney)
        let expectableProfitNormalizedScore = Double(expectableProfit / 5)
        let difficultyNormalizedScore = Double(3 / difficulty)
        let score = timeToMarketNormalizedScore + requiredMoneyNormalizedScore + expectableProfitNormalizedScore + difficultyNormalizedScore
        
        return score
    }
    
    // MARK: - IBAction
    
    @IBAction func selectCategory(_ sender: UIButton) {
        UIHelper.showCategoryAction(from: self) { [weak self] category in
            guard let category = category else {
                return
            }
            self?.selectedCategory = category
        }
    }
    
    @IBAction func timeToMarket(_ sender: UIButton) {
        showStandartPicker(fieldName: "Time To Market",
                           fieldButton: sender) { [weak self] (count) in
            self?.timeToMarketCosmosView.rating = Double(count)
        }
    }
    
    @IBAction func requiredMoney(_ sender: UIButton) {
        showStandartPicker(fieldName: "Required Money",
                           fieldButton: sender) { [weak self] (count) in
            self?.requiredMoneyCosmosView.rating = Double(count)
        }
    }
    
    @IBAction func expectableProfit(_ sender: UIButton) {
        showStandartPicker(fieldName: "Expectable Profit",
                           fieldButton: sender) { [weak self] (count) in
            self?.profitCosmosView.rating = Double(count)
        }
    }
    
    @IBAction func difficulty(_ sender: UIButton) {
        showStandartPicker(fieldName: "Difficulty",
                           fieldButton: sender) { [weak self] (count) in
            self?.difficultyCosmosView.rating = Double(count)
        }
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        guard let title = titleTextField.text, !title.isEmpty else {
            UIHelper.showErrorAlert(with: "Enter title please")
            return
        }
        
        guard timeToMarketCosmosView.rating != 0
            && requiredMoneyCosmosView.rating != 0
            && profitCosmosView.rating != 0
            && difficultyCosmosView.rating != 0 else {
                UIHelper.showErrorAlert(with: "Empty ratings")
                return
        }
        
        guard let description = descriptionTextView.text, !description.isEmpty else {
            UIHelper.showErrorAlert(with: "Enter description pls")
            return
        }
        
        let rating = calculateScore(timeToMarket: Int(timeToMarketCosmosView.rating),
                                    requiredMoney: Int(requiredMoneyCosmosView.rating),
                                    expectableProfit: Int(profitCosmosView.rating),
                                    difficulty: Int(difficultyCosmosView.rating))
        
        DatabaseManager.addIdea(name: title, description: description, rating: rating, category: selectedCategory)
        
        navigationController?.popViewController(animated: true)
    }
}
