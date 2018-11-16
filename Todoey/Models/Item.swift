//
//  Item.swift
//  Todoey
//
//  Created by patrick_shi on 2018/11/16.
//  Copyright © 2018 patrick_shi. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
