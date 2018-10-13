//
//  CategoryTableViewController.swift
//  ToDo-List
//
//  Created by Eric Sans Alvarez on 13/10/2018.
//  Copyright © 2018 Eric Sans Alvarez. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
	
	var categoryArray = [Category]()
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
		loadItems()
    }
	
	//MARK: - TableView Datasource Methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categoryArray.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let categoryCell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
		
		let category = categoryArray[indexPath.row]
		categoryCell.textLabel?.text = category.name
		
		return categoryCell
	}
	
	//MARK: - TableView Delegate Methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//To be implemented
	}

	//MARK: - Add New Categories
	
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		
		var textField = UITextField()
		let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
		let action = UIAlertAction(title: "Add Category", style: .default) { (action) in

			//If text is not blank
			guard (textField.text != "") else { return }
			let newCategory = Category(context: self.context)
			newCategory.name = textField.text

			self.categoryArray.append(newCategory)

			self.saveItems()
		}

		alert.addTextField { (alertTextField) in
			alertTextField.placeholder = "Create new list"
			textField = alertTextField
		}

		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}
	
	//MARK: - Data Manipulation Methods
	
	func saveItems() {
		do {
			try context.save()
		} catch {
			print("Error while saving context \(error)")
		}
		self.tableView.reloadData()
	}
	
	func loadItems(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
		do {
			categoryArray = try context.fetch(request)
		} catch {
			print("Error while loading context \(error)")
		}
		self.tableView.reloadData()
	}
	
}
