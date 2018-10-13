//
//  CategoryTableViewController.swift
//  ToDo-List
//
//  Created by Eric Sans Alvarez on 13/10/2018.
//  Copyright © 2018 Eric Sans Alvarez. All rights reserved.
//

import UIKit
import CoreData

class CategoriesViewController: UITableViewController {
	
	var categories = [Category]()
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
		loadItems()
    }
	
	//MARK: - TableView Datasource Methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categories.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let categoryCell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
		
		let category = categories[indexPath.row]
		categoryCell.textLabel?.text = category.name
		
		return categoryCell
	}
	
	//MARK: - TableView Delegate Methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "goToItems", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destinationVC = segue.destination as! ToDoListViewController
		
		guard let indexPath = tableView.indexPathForSelectedRow else { return }
		destinationVC.selectedCategory = categories[indexPath.row]
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

			self.categories.append(newCategory)

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
			categories = try context.fetch(request)
		} catch {
			print("Error while loading context \(error)")
		}
		self.tableView.reloadData()
	}
	
}
