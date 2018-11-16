//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by patrick_shi on 2018/11/15.
//  Copyright © 2018 patrick_shi. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
    }
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Category", message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            guard let text = textField.text, !text.isEmpty else {
                return
            }
            
            let newCategory = Category(context: self.context)
            newCategory.name = text
            self.categoryArray.append(newCategory)
            self.saveCategory()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Input new category here"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Table View Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    
    //MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
//        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            context.delete(categoryArray[indexPath.row])
            categoryArray.remove(at: indexPath.row)
            saveCategory()
        }
    }
    
    //MARK: - Data Manipulation Methods
    func saveCategory() {
        do {
            try context.save()
        } catch {
            print("Error save category \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategory(with request : NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetch category \(error)")
        }
        tableView.reloadData()
    }
}
