//
//  Item.swift
//  ToDo-List
//
//  Created by Eric Sans Alvarez on 21/10/2018.
//  Copyright © 2018 Eric Sans Alvarez. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
	@objc dynamic var title: String = ""
	@objc dynamic var done: Bool = false
	
	// Inverse relationship
	var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
