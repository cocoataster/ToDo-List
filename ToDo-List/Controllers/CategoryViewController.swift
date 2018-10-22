//
//  CategoryTableViewController.swift
//  ToDo-List
//
//  Created by Eric Sans Alvarez on 13/10/2018.
//  Copyright © 2018 Eric Sans Alvarez. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
	
	// Can only fail the first time according to Realm?
	let realm = try! Realm()
	
	// Results is the auto-updating type returned by Realm
	var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.rowHeight = 80.0
		
		loadCategories()
    }
	
	//MARK: - TableView Datasource Methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categories?.count ?? 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let categoryCell = super.tableView(tableView, cellForRowAt: indexPath)
		
		categoryCell.textLabel?.text = categories?[indexPath.row].name ?? "No categories set yet"
		categoryCell.backgroundColor = UIColor(hexString: (categories?[indexPath.row].color)!)
		
		return categoryCell
	}
	
	//MARK: - TableView Delegate Methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "goToItems", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destinationVC = segue.destination as! ToDoListViewController
		
		guard let indexPath = tableView.indexPathForSelectedRow else { return }
		destinationVC.selectedCategory = categories?[indexPath.row]
	}

	//MARK: - Add New Categories
	
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		
		var textField = UITextField()
		let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
		let action = UIAlertAction(title: "Add Category", style: .default) { (action) in

			//If text is not blank
			guard (textField.text != "") else { return }
			
			let newCategory = Category()
			newCategory.name = textField.text!
			newCategory.color = UIColor.randomFlat.hexValue()

			self.save(category: newCategory)
		}

		alert.addTextField { (alertTextField) in
			alertTextField.placeholder = "Create new list"
			textField = alertTextField
		}

		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}
	
	//MARK: - Data Manipulation Methods
	
	func save(category: Category) {
		do {
			try realm.write {
				realm.add(category)
			}
		} catch {
			print("Error while saving \(error)")
		}
		tableView.reloadData()
	}
	
	func loadCategories() {
		categories = realm.objects(Category.self)
		tableView.reloadData()
	}
	
	override func deleteRow(at indexPath: IndexPath) {
		if let categoryForDeletion = self.categories?[indexPath.row] {
			do {
				try realm.write {
					realm.delete(categoryForDeletion)
				}
			} catch {
				print("Error deleting category \(error)")
			}
		}
	}
}
