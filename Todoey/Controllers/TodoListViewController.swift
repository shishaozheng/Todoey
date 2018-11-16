//
//  ViewController.swift
//  Todoey
//
//  Created by patrick_shi on 2018/11/14.
//  Copyright © 2018 patrick_shi. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    var itemArray: Results<Item>?
    let realm = try! Realm()
    
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
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        if let item = itemArray?[indexPath.row] {
            cell.accessoryType = item.done ? .checkmark : .none
            updateItemText(cell: cell, title: item.title, done: item.done)
        } else {
            updateItemText(cell: cell, title: "No Items Added", done: false)
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = itemArray?[indexPath.row]{
            do {
                try realm.write {
                    item.done = !item.done
                }
                updateItemText(cell: tableView.cellForRow(at: indexPath)!, title: item.title, done: item.done)
            } catch {
                print("Error updating items, \(error)")
            }
        }
        self.tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = itemArray?[indexPath.row]{
                do {
                    try realm.write {
                        realm.delete(item)
                    }
                } catch {
                    print("Error delete items, \(error)")
                }
            }
            self.tableView.reloadData()
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

    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert  = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //TODO add to the item array
            guard let text = textField.text, !text.isEmpty else {
                return
            }
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = text
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error Saving items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Input new item here"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        itemArray = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }
}

//MARK: - Search Bar Delegate
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

