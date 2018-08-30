//
//  IdeasTableViewController.swift
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 18.07.18.
//

import UIKit
import CoreStore

class IdeasTableViewController: UITableViewController {
    
    private var ideas: ListMonitor<Idea>!

    private var selectedIdea: Idea? {
        didSet {
            guard let idea = selectedIdea else {
                return
            }
            performSegue(withIdentifier: R.segue.ideasTableViewController.createIdeaButtonSegue.identifier, sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
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
                let selectedIdea = selectedIdea {
                destinationVC.configure(with: selectedIdea)
            }
        default: break
        }
    }
    
    // MARK: - Private
    
    private func loadData() {
        ideas = CoreStore.monitorList(From<Idea>(), OrderBy<Idea>(
            .descending("score"),
            .ascending("title")))
        ideas.addObserver(self)
    }
    
    func exportIdeasToClipboard() {
        var ideasTxt = ""
        for idea in ideas.objectsInAllSections() {
            ideasTxt += idea.getIdeaAsString()
            ideasTxt += "********************** \n"
        }
        let clipboard = UIPasteboard.general
        clipboard.string = ideasTxt
    }
    
    // MARK: - IBAction
}

//MARK: - ListSectionObserver

extension IdeasTableViewController: ListSectionObserver {
    
    func listMonitor(_ monitor: ListMonitor<Idea>, didMoveObject object: Idea, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        tableView.deleteRows(at: [fromIndexPath], with: .fade)
        tableView.insertRows(at: [toIndexPath], with: .fade)
    }
    
    
    func listMonitor(_ monitor: ListMonitor<Idea>, didInsertObject object: Idea, toIndexPath indexPath: IndexPath) {
        tableView.insertRows(at: [indexPath], with: .fade)
    }
    
    func listMonitor(_ monitor: ListMonitor<Idea>, didDeleteObject object: Idea, fromIndexPath indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .fade)
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

        let edit = UITableViewRowAction(style: .normal, title: "Edit") { [weak self] (action, indexPath) in
            guard let idea = self?.ideas.objectsInAllSections()[indexPath.row] else {
                return
            }
            self?.selectedIdea = idea
        }
        
        return [delete, edit]
    }
}
