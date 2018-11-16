//
//  ViewController.swift
//  Todoey
//
//  Created by patrick_shi on 2018/11/14.
//  Copyright © 2018 patrick_shi. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Category? {
        didSet {
            // Load storage data
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - TableView Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.accessoryType = item.done ? .checkmark : .none
        updateItemText(cell: cell, title: item.title!, done: item.done)
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        let cell = tableView.cellForRow(at: indexPath)
        let title = cell?.textLabel?.text
        updateItemText(cell: cell!, title: title!, done: itemArray[indexPath.row].done)
        
        saveAndUpdateItems()
    
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            saveAndUpdateItems()
        }
    }
    
    //MARK: - Done Item Label Style
    func updateItemText(cell: UITableViewCell, title: String, done: Bool) {
        if done {
            let doneAttributes = [NSAttributedString.Key.strikethroughStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.strikethroughColor: UIColor.blue] as [NSAttributedString.Key : Any]
            let attrString = NSAttributedString(string: title, attributes: doneAttributes)
            cell.textLabel?.attributedText = attrString
        } else {
            cell.textLabel?.attributedText = NSAttributedString(string: title, attributes: nil)
        }
    }

    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert  = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //TODO add to the item array
            guard let text = textField.text, !text.isEmpty else {
                return
            }

            let newItem = Item(context: self.context)
            newItem.title = text
            newItem.parentCategory = self.selectedCategory
            newItem.done = false
            self.itemArray.append(newItem)
            
            self.saveAndUpdateItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Input new item here"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Core Data Operation
    func saveAndUpdateItems() {
        do {
            try context.save()
        } catch {
            print("Error saving new item \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predict: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predict {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, categoryPredicate])
            request.predicate = compoundPredicate
        } else {
            request.predicate = categoryPredicate
        }

        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching items \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK: - Search Bar Delegate
extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predict: searchPredicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Reload all items when clear serach text
        if searchText.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

