//
//  ManageCategoriesTableViewController.swift
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 3.08.18.
//

import UIKit
import CoreStore

class ManageCategoriesTableViewController: UITableViewController {
    
    private var categories: ListMonitor<Category>!
    private var selectedCategory: Category? {
        didSet {
            guard selectedCategory != nil else {
                return
            }
            performSegue(withIdentifier: R.segue.manageCategoriesTableViewController.showAddCategory.identifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeSelectedCategory()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    deinit {
        categories.removeObserver(self)
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case R.segue.manageCategoriesTableViewController.showAddCategory.identifier:
            if let destinationVC = segue.destination as? AddCategoryViewController,
                let selectedCategory = selectedCategory {
                destinationVC.configure(with: selectedCategory)
            }
        default: break
        }
    }
    
    // MARK: - Private
    
    private func loadData() {
        categories = CoreStore.monitorList(From<Category>(), OrderBy<Category>(.ascending("title")))
        categories.addObserver(self)
    }
    
    private func removeSelectedCategory() {
        selectedCategory = nil
    }
    
    // MARK: - IBAction
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: R.segue.manageCategoriesTableViewController.showAddCategory.identifier, sender: nil)
    }
    
}

// MARK: - UITableViewDelegate

extension ManageCategoriesTableViewController {
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            let category = self!.categories.objectsInAllSections()[indexPath.row]
            DatabaseManager.delete(category: category)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { [weak self] (action, indexPath) in
            self?.selectedCategory = self!.categories.objectsInAllSections()[indexPath.row]
        }
        
        edit.backgroundColor = .orange
        
        return [delete, edit]
    }
}

// MARK: - UITableViewDatasource

extension ManageCategoriesTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return categories.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.numberOfObjectsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.categoryCell.identifier) as! CategoryTableViewCell
        
        cell.configure(with: categories[indexPath.row])
        
        return cell
    }
    
}

//MARK: - ListSectionObserver

extension ManageCategoriesTableViewController: ListSectionObserver {
    
    func listMonitor(_ monitor: ListMonitor<Category>, didMoveObject object: Category, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        tableView.deleteRows(at: [fromIndexPath], with: .fade)
        tableView.insertRows(at: [toIndexPath], with: .fade)
    }

    
    func listMonitor(_ monitor: ListMonitor<Category>, didInsertObject object: Category, toIndexPath indexPath: IndexPath) {
        tableView.insertRows(at: [indexPath], with: .fade)
    }
    
    func listMonitor(_ monitor: ListMonitor<Category>, didDeleteObject object: Category, fromIndexPath indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .fade)
    }

    func listMonitor(_ monitor: ListMonitor<Category>, didUpdateObject object: Category, atIndexPath indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<Category>) {
        tableView.endUpdates()
    }
    
    func listMonitorWillChange(_ monitor: ListMonitor<Category>) {
        tableView.beginUpdates()
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<Category>) {
    }
    
    func listMonitorWillRefetch(_ monitor: ListMonitor<Category>) {
    }
}

