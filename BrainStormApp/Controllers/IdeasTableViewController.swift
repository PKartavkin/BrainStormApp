//
//  IdeasTableViewController.swift
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 18.07.18.
//

import UIKit
import CoreStore

class IdeasTableViewController: UITableViewController {

    private enum Const {
        static let ideaSeparator = "********************** \n"
    }

    private var ideas: ListMonitor<Idea>!

    @IBOutlet weak var exportButton: UIBarButtonItem!

    private var selectedIdea: Idea?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isLaunchedBefore()  {
            UIHelper.showGreetingAlert()
            presetupCategories()
        }
        loadData()
        setupExportButton()
    }
    
    deinit {
        ideas.removeObserver(self)
    }

    //MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case R.segue.ideasTableViewController.createIdeaButtonSegue.identifier:
            if let destinationVC = segue.destination as? AddIdeaViewController,
                let idea = selectedIdea {
                destinationVC.configure(with: idea)
                selectedIdea = nil
            }
        default: break
        }
    }
    
    // MARK: - Private

    private func hasIdeas() -> Bool {
        return ideas.objectsInAllSections().count > 0
    }

    private func setupExportButton() {
        exportButton.isHidden = !hasIdeas()
    }

    private func isLaunchedBefore() -> Bool {
        let isLaunchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore") ? true : false
        UserDefaults.standard.set(true, forKey: "launchedBefore")
        return isLaunchedBefore
    }
    
    private func presetupCategories() {
        DatabaseManager.addCategory("Retail", color: .blue, colorName: "Blue", icon: #imageLiteral(resourceName: "blue_category_icon"))
        DatabaseManager.addCategory("Mobile apps", color: .green, colorName: "Green", icon: #imageLiteral(resourceName: "green_category_icon"))
        DatabaseManager.addCategory("Media", color: .orange, colorName: "Orange", icon: #imageLiteral(resourceName: "orange_category_icon"))
    }
    
    private func loadData() {
        ideas = CoreStore.monitorList(From<Idea>(), OrderBy<Idea>(
            .descending("score"),
            .ascending("title")))
        ideas.addObserver(self)
    }
    
    func exportIdeasToClipboard() {
        let ideasTxt = ideas.objectsInAllSections()
            .map {$0.getIdeaAsString()}
            .joined(separator: Const.ideaSeparator)
        let clipboard = UIPasteboard.general
        clipboard.string = ideasTxt
    }
    
    // MARK: - IBAction

    @IBAction func export(_ sender: UIBarButtonItem) {
        UIHelper.showExportAlert(with: ideas.objectsInAllSections().count)
        exportIdeasToClipboard()
    }

}

//MARK: - ListSectionObserver

extension IdeasTableViewController: ListSectionObserver {
    
    func listMonitor(_ monitor: ListMonitor<Idea>, didMoveObject object: Idea, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        tableView.deleteRows(at: [fromIndexPath], with: .fade)
        tableView.insertRows(at: [toIndexPath], with: .fade)
    }
    
    
    func listMonitor(_ monitor: ListMonitor<Idea>, didInsertObject object: Idea, toIndexPath indexPath: IndexPath) {
        tableView.insertRows(at: [indexPath], with: .fade)
        setupExportButton()
    }
    
    func listMonitor(_ monitor: ListMonitor<Idea>, didDeleteObject object: Idea, fromIndexPath indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .fade)
        setupExportButton()
    }

    func listMonitor(_ monitor: ListMonitor<Idea>, didUpdateObject object: Idea, atIndexPath indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<Idea>) {
        tableView.endUpdates()
    }
    
    func listMonitorWillChange(_ monitor: ListMonitor<Idea>) {
        tableView.beginUpdates()
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<Idea>) {
    }
    
    func listMonitorWillRefetch(_ monitor: ListMonitor<Idea>) {
    }
}

// MARK: - UITableViewDelegate

extension IdeasTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return ideas.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ideas.numberOfObjectsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.ideaCell.identifier) as! IdeaTableViewCell
        
        cell.configure(with: ideas[indexPath.row])
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension IdeasTableViewController {
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            let idea = self!.ideas.objectsInAllSections()[indexPath.row]
            DatabaseManager.delete(idea: idea)
        }
        
        return [delete]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let idea = ideas.objectsInAllSections()[indexPath.row]
        selectedIdea = idea
        performSegue(withIdentifier: R.segue.ideasTableViewController.createIdeaButtonSegue.identifier, sender: nil)
    }
}
