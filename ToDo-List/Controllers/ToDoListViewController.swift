//
//  ViewController.swift
//  ToDo-List
//
//  Created by Eric Sans Alvarez on 11/10/2018.
//  Copyright © 2018 Eric Sans Alvarez. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {

	var todoItems: Results<Item>?
	var realm = try! Realm()
	
	var selectedCategory : Category? {
		//Will call loadItems as soon as selectedCategory is set
		didSet {
			loadItems()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	//MARK: - TableView DataSource Methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return todoItems?.count ?? 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let itemCell = tableView.dequeueReusableCell(withIdentifier: "toDoItemCell", for: indexPath)
		
		if let item = todoItems?[indexPath.row] {
			itemCell.textLabel?.text = item.title
			itemCell.accessoryType = item.done ? .checkmark : .none
		} else {
			itemCell.textLabel?.text = "Want to add an item? Just click the + button!"
			itemCell.accessoryType = .none
		}
		
		return itemCell
	}
	
	//MARK: - TableView Delegate Methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if let item = todoItems?[indexPath.row] {
			do {
				try realm.write {
					item.done = !item.done
				}
			} catch {
				print("Error saving done status\(error)")
			}
		}
		self.tableView.reloadData()
		
		//Avoid gray area selected
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }
		if let item = todoItems?[indexPath.row] {
			do {
				try realm.write {
					realm.delete(item)
				}
			} catch {
				print("Error while deleting \(error)")
			}
		}
		self.tableView.deleteRows(at: [indexPath], with: .bottom)
	}
	
	//MARK: - Add New Items
	
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		
		var textField = UITextField()
		let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
		let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
			//Save Text
			guard (textField.text != "") else { return }
			
			//Review
			if let currentCategory = self.selectedCategory {
				do {
					try self.realm.write {
						let newItem = Item()
						newItem.title = textField.text!
						newItem.dateCreated = Date()
						currentCategory.items.append(newItem)
					}
				} catch {
					print("Error while saving \(error)")
				}
			}
			self.tableView.reloadData()
		}
		
		alert.addTextField { (alertTextField) in
			alertTextField.placeholder = "Create new item"
			textField = alertTextField
		}
		
		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}
	
	func loadItems() {
		todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
		tableView.reloadData()
	}
}

//MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate {

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
		tableView.reloadData()
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard (searchBar.text!.isEmpty) else { return }
		loadItems()

		//Background action
		DispatchQueue.main.async {
			searchBar.resignFirstResponder()
		}
	}
}

