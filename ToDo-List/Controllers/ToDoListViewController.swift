//
//  ViewController.swift
//  ToDo-List
//
//  Created by Eric Sans Alvarez on 11/10/2018.
//  Copyright © 2018 Eric Sans Alvarez. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

	var itemArray = [Item]()
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
		
		//loadItems()
		
	}
	
	//MARK: - TableView DataSource Methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemArray.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "toDoItemCell", for: indexPath)
		
		let item = itemArray[indexPath.row]
		
		cell.textLabel?.text = item.title
		
		cell.accessoryType = item.done ? .checkmark : .none
		
		return cell
	}
	
	//MARK: - TableView Delegate Methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		//Delete items insead of marking them
//		context.delete(itemArray[indexPath.row])
//		itemArray.remove(at: indexPath.row)
		
		itemArray[indexPath.row].done = !itemArray[indexPath.row].done
		saveItems()
		
		//Avoid gray area selected
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	//MARK: - Add New Items
	
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		
		var textField = UITextField()
		
		let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
		
		let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
			//Save Text
			guard (textField.text != "") else { return }
			
			//It would be nice to change the initializer to something like (title: String, done: Bool)
			let newItem = Item(context: self.context)
			newItem.title = textField.text
			newItem.done = false
			
			self.itemArray.append(newItem)
			
			self.saveItems()
		}
		
		alert.addTextField { (alertTextField) in
			alertTextField.placeholder = "Create new item"
			textField = alertTextField
		}
		
		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}
	
	//MARK: - Model Manipulation Methods
	
	func saveItems() {
		do {
			try context.save()
		} catch {
			print("Error while saving context \(error)")
		}
		
		self.tableView.reloadData()
	}
	
	func loadItems() {
		let request : NSFetchRequest<Item> = Item.fetchRequest()
		do {
			itemArray = try context.fetch(request)
		} catch {
			print("Error while loading context \(error)")
		}
	}
}

