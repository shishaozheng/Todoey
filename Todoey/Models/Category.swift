//
//  Category.swift
//  Todoey
//
//  Created by patrick_shi on 2018/11/16.
//  Copyright © 2018 patrick_shi. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
