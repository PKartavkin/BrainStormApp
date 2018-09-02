//
//  AddCategoryViewController.swift
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 3.08.18.
//

import UIKit

class AddCategoryViewController: UIViewController {
    
    private var category: Category?
    private var selectedColor: UIColor?
    
    @IBOutlet weak var colorImageView: UIImageView!
    

    @IBOutlet weak var colorLabel: UILabel! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(changeColor))
            colorLabel.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var nameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setImageTapGesture()
    }
    
    // MARK: - Public
    
    func configure(with category: Category) {
        self.category = category
    }
    
    // MARK - Private
    
    private func loadData() {
        guard let category = category else {
            return
        }
        
        nameTextField.text = category.title
        colorImageView.image = category.icon
        colorLabel.text = category.colorTitle
        selectedColor = category.color
    }
    
    private func setImageTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddCategoryViewController.changeColor))
        
        colorLabel.addGestureRecognizer(tap)
        colorLabel.isUserInteractionEnabled = true
        
        colorImageView.addGestureRecognizer(tap)
        colorImageView.isUserInteractionEnabled = true
    }
    
    @objc private func changeColor() {
        UIHelper.showColors(from: self) { [weak self] categoryImage in
            guard let categoryImage = categoryImage else {
                return
            }
            self?.colorImageView.image = categoryImage.image
            self?.colorLabel.text = categoryImage.name
            self?.selectedColor = categoryImage.color
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        guard let name = nameTextField.text, !name.isEmpty else {
            UIHelper.showErrorAlert(with: "Please enter title")
            return
        }
        
        guard let selectedColor = selectedColor,
            let colorName = colorLabel.text,
            let colorImage = colorImageView.image else {
                UIHelper.showErrorAlert(with: "Please select color")
                return
        }

        // COULD BE REFACTORED
        if let category = category {
            category.color = selectedColor
            category.title = name
            category.colorTitle = colorName
            category.icon = colorImage
            DatabaseManager.edit(category: category)
        } else {
        
            DatabaseManager.addCategory(name,
                                        color: selectedColor,
                                        colorName: colorName,
                                        icon: colorImage)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
