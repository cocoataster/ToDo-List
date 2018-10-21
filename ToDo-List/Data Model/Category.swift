//
//  Category.swift
//  ToDo-List
//
//  Created by Eric Sans Alvarez on 21/10/2018.
//  Copyright © 2018 Eric Sans Alvarez. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
	@objc dynamic var name: String = ""
	
	// Array of Items. Establish the relationship between objects
	let items = List<Item>()
}
