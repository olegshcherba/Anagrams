//
//  UserModel.swift
//  Anagrams
//
//  Created by MultisAudios on 6/17/19.
//  Copyright © 2019 MultisAudios. All rights reserved.
//

import Foundation

// Made for getting data from Firebase server
class UserModel {
  
  var name = ""
  var score = 0
  var userID = ""
  
  init(name: String, score: Int, userID: String) {
    self.name = name
    self.score = score
    self.userID = userID
  }
}
