//
//  AddIdeaViewController
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 22.07.18.
//

import UIKit
import Cosmos
import KMPlaceholderTextView

class AddIdeaViewController: UIViewController, UITextFieldDelegate {
    
    private enum Constant {
        static let defaultRating: Double = 5
    }
    
    @IBOutlet weak var categoryButton: UIButton!
    
    private var selectedCategory: Category? {
        didSet {
            guard let selectedCategory = selectedCategory else {
                categoryButton.setTitle("No category", for: .normal)
                return
            }
            categoryButton.setTitle(selectedCategory.title, for: .normal)
        }
    }

    private var idea: Idea?
    
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
    
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!
    
    @IBOutlet weak var titleTextField: UITextField!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedCategory = idea?.category
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRatings()
        fillIdea()
        titleTextField.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 32
    }
    

    // MARK: - Public

    func configure(with idea: Idea) {
        self.idea = idea
    }

    // MARK: - Private
    
    private func setupRatings() {
        func updateRating(ratingView: CosmosView, ratingLabel: UILabel) {
            let updateRating: (Double) -> Void = { (rating) in
                ratingView.rating = rating.rounded(.up)
                ratingLabel.text = String(Int(rating.rounded(.up)))
            }
            ratingView.didTouchCosmos = updateRating
        }
        
        updateRating(ratingView: timeToMarketCosmosView, ratingLabel: timeToMarketLabel)
        updateRating(ratingView: requiredMoneyCosmosView, ratingLabel: requiredMoneyLabel)
        updateRating(ratingView: profitCosmosView, ratingLabel: expectedProfitLabel)
        updateRating(ratingView: difficultyCosmosView, ratingLabel: difficultyLabel)
    }

    private func fillIdea() {
        // This is not the best implementation every. We could make touple or something like this between the cosmosView and the label but this implementation will do the work
        func setRating(for ratingView: CosmosView, and label: UILabel, with value: Int) {
            ratingView.rating = Double(value)
            label.text = "\(value)"
        }

        guard let idea = idea else {
            return
        }
        titleTextField.text = idea.title
        descriptionTextView.text = idea.desc
        selectedCategory = idea.category

        setRating(for: timeToMarketCosmosView, and: timeToMarketLabel, with: Int(idea.timeToMarket))
        setRating(for: requiredMoneyCosmosView, and: requiredMoneyLabel, with: Int(idea.requiredMoney))
        setRating(for: profitCosmosView, and: expectedProfitLabel, with: Int(idea.expectedProfit))
        setRating(for: difficultyCosmosView, and: difficultyLabel, with: Int(idea.difficulty))
    }
    
    private func calculateScore(timeToMarket: Int, requiredMoney: Int, expectableProfit: Int, difficulty: Int) -> Double {
        //zero element is unused
        let requiredMoneyMapping = [0.0,3.0,2.75,2.5,2.1,1.7,1.2,0.7,0.2,0.1,0.0]
        let timeToMarketMapping = [0.0,2.0,1.9,1.8,1.6,1.4,1.0,0.6,0.4,0.2,0.0]
        let expectableProfitMapping = [0.0,0.0,0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0]
        let difficultyMapping = requiredMoneyMapping
        let score = timeToMarketMapping[timeToMarket] + requiredMoneyMapping[requiredMoney] + expectableProfitMapping[expectableProfit] + difficultyMapping[difficulty]
        let scoreRounded = round(score / 0.1) * 0.1
        return scoreRounded
    }

    // MARK: - IBAction

    @IBAction func selectCategory(_ sender: UIButton) {
        UIHelper.showCategoryAction(from: self) { [weak self] category, cancelClicked in
            if (!cancelClicked) {
                self?.selectedCategory = category
            }
        }
    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    
    @IBAction func done(_ sender: UIBarButtonItem) {
        guard let title = titleTextField.text, !title.isEmpty else {
            UIHelper.showErrorAlert(with: "Please enter idea name")
            return
        }
        
        guard let description = descriptionTextView.text, !description.isEmpty else {
            UIHelper.showErrorAlert(with: "Please enter description")
            return
        }
        
        let rating = calculateScore(timeToMarket: Int(timeToMarketCosmosView.rating),
                                    requiredMoney: Int(requiredMoneyCosmosView.rating),
                                    expectableProfit: Int(profitCosmosView.rating),
                                    difficulty: Int(difficultyCosmosView.rating))
        // COULD BE REFACTORED
        if let idea = idea {
            idea.title = title
            idea.desc = description
            idea.timeToMarket = Int16(timeToMarketCosmosView.rating)
            idea.expectedProfit = Int16(profitCosmosView.rating)
            idea.difficulty = Int16(difficultyCosmosView.rating)
            idea.requiredMoney = Int16(requiredMoneyCosmosView.rating)
            idea.category = selectedCategory
            idea.score = rating

            DatabaseManager.edit(idea: idea)
        } else {
        
            DatabaseManager.addIdea(name: title,
                                    description: description,
                                    timeToMarket: Int16(timeToMarketCosmosView.rating),
                                    requiredMoney: Int16(requiredMoneyCosmosView.rating),
                                    expectedProfit: Int16(profitCosmosView.rating),
                                    difficulty: Int16(difficultyCosmosView.rating),
                                    rating: rating,
                                    category: selectedCategory)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
