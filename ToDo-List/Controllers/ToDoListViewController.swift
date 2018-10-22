//
//  ViewController.swift
//  ToDo-List
//
//  Created by Eric Sans Alvarez on 11/10/2018.
//  Copyright © 2018 Eric Sans Alvarez. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {

	var realm = try! Realm()
	
	var todoItems: Results<Item>?
	
	var selectedCategory : Category? {
		//Will call loadItems as soon as selectedCategory is set
		didSet {
			loadItems()
		}
	}
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.rowHeight = 80.0
	}
	
	override func viewWillAppear(_ animated: Bool) {
		title = selectedCategory?.name
		guard let colorHex = selectedCategory?.color else { fatalError() }
		updateNavBar(withHexColor: colorHex)
	}
	
	override func willMove(toParent parent: UIViewController?) {
		updateNavBar(withHexColor: "FF5855")
	}
	
	//MARK: - Navigation Bar View
	
	func updateNavBar(withHexColor colorHexCode: String) {
		guard let navBar = navigationController?.navigationBar else { fatalError() }
		guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError() }
		
		navBar.barTintColor = navBarColor
		navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
		navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
		searchBar.backgroundColor = navBarColor
	}
	
	//MARK: - TableView DataSource Methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return todoItems?.count ?? 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let itemCell = super.tableView(tableView, cellForRowAt: indexPath)
		
		if let item = todoItems?[indexPath.row] {
			itemCell.textLabel?.text = item.title
			itemCell.accessoryType = item.done ? .checkmark : .none
			let percentage = CGFloat(indexPath.row) / CGFloat(todoItems!.count)
			let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: percentage)
			itemCell.backgroundColor = color
			itemCell.textLabel?.textColor = ContrastColorOf(color!, returnFlat: true)
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
		tableView.reloadData()
		
		//Avoid gray area selected
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	//MARK: - Add New Items
	
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		
		var textField = UITextField()
		let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
		let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
			
			// If text is not blank
			guard (textField.text != "") else { return }
			
			// Verify category did set and add item to array
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
	
	//MARK: - Data Manipulation Methods
	
	func loadItems() {
		todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
		tableView.reloadData()
	}
	
	override func deleteRow(at indexPath: IndexPath) {
		if let itemForDeletion = todoItems?[indexPath.row] {
			do {
				try realm.write {
					realm.delete(itemForDeletion)
				}
			} catch {
				print("Error deleting item \(error)")
			}
		}
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

