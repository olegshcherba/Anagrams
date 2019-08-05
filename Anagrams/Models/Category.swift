//
//  Category.swift
//  Anagrams
//
//  Created by MultisAudios on 2/21/19.
//  Copyright © 2019 MultisAudios. All rights reserved.
//

import Foundation

class Category {
  
  var name = ""
  var checked = false
  var difficulty: Difficulty = .easy
  
  enum Difficulty: Int {
    case easy
    case medium
    case hard
  }
  
  func toggleChecked() {
    checked = !checked
  }
}
