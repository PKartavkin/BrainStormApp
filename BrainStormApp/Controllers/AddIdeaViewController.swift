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

    private var ratingTableViewControllerController: RatingTableViewController?

    @IBOutlet weak var ratingContainerView: UIView!
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
    
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!
    
    @IBOutlet weak var titleTextField: UITextField!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedCategory = idea?.category
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }

        switch identifier {
        case R.segue.addIdeaViewController.embededRatingTVC.identifier:
            let destinationController = segue.destination as! RatingTableViewController
            ratingTableViewControllerController = destinationController
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

    private func fillIdea() {
        // This is not the best implementation every. We could make touple or something like this between the cosmosView and the label but this implementation will do the work
        func setRating(for ratingView: CosmosView, and label: UILabel, with value: Int) {
            ratingView.rating = Double(value)
            label.text = "\(value)"
        }

        guard let idea = idea, let ratingTableViewControllerController = ratingTableViewControllerController else {
            return
        }
        titleTextField.text = idea.title
        descriptionTextView.text = idea.desc
        selectedCategory = idea.category

        ratingTableViewControllerController.timeToMarketScore = Int(idea.timeToMarket)
        ratingTableViewControllerController.requiredMoneyScore = Int(idea.requiredMoney)
        ratingTableViewControllerController.expectedProfitScore = Int(idea.expectedProfit)
        ratingTableViewControllerController.difficultyScore = Int(idea.difficulty)
    }
    
    private func calculateScore(timeToMarket: Int, requiredMoney: Int, expectableProfit: Int, difficulty: Int) -> Double {
        //zero element is unused
        let requiredMoneyMapping = [0.0,3.0,2.8,2.5,2.1,1.7,1.2,0.7,0.2,0.1,-0.3]
        let timeToMarketMapping = [0.0,2.0,1.9,1.8,1.6,1.4,1.0,0.6,0.4,0.1,-0.3]
        let expectableProfitMapping = [0.0,-0.3,0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0]
        let difficultyMapping = requiredMoneyMapping
        let score = timeToMarketMapping[timeToMarket] + requiredMoneyMapping[requiredMoney] + expectableProfitMapping[expectableProfit] + difficultyMapping[difficulty]
        let scoreRounded = score <= 0 ? 0 : round(score * 10) / 10
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

        guard let ratingTableViewController = ratingTableViewControllerController else {
            return
        }

        let timeToMarketScore = ratingTableViewController.timeToMarketScore
        let requiredMoneyScore = ratingTableViewController.requiredMoneyScore
        let expectedProfitScore = ratingTableViewController.expectedProfitScore
        let difficultyScore = ratingTableViewController.difficultyScore

        
        let rating = calculateScore(timeToMarket: Int(timeToMarketScore),
                                    requiredMoney: Int(requiredMoneyScore),
                                    expectableProfit: Int(expectedProfitScore),
                                    difficulty: Int(difficultyScore))
        // COULD BE REFACTORED
        if let idea = idea {
            idea.title = title
            idea.desc = description
            idea.timeToMarket = Int16(timeToMarketScore)
            idea.expectedProfit = Int16(expectedProfitScore)
            idea.difficulty = Int16(difficultyScore)
            idea.requiredMoney = Int16(requiredMoneyScore)
            idea.category = selectedCategory
            idea.score = rating

            DatabaseManager.edit(idea: idea)
        } else {
        
            DatabaseManager.addIdea(name: title,
                                    description: description,
                                    timeToMarket: Int16(timeToMarketScore),
                                    requiredMoney: Int16(requiredMoneyScore),
                                    expectedProfit: Int16(expectedProfitScore),
                                    difficulty: Int16(difficultyScore),
                                    rating: rating,
                                    category: selectedCategory)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
