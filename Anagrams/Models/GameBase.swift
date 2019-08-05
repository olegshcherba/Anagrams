//
//  DataFunc.swift
//  Anagrams
//
//  Created by MultisAudios on 05.10.2018.
//  Copyright © 2018 MultisAudios. All rights reserved.
//

import Foundation

struct GameBase: Codable {
  
  // MARK: - Instance properties
  
  static var categoryNames = [Category]()
  static var wordsArr = [String]()
  static var words2D = [Array<String>]()
  static var score = 0
  static var scoresArray = [0]
  static var seconds = 0
  static var timer = Timer()
  static var lives = 3
  static var categoryChecked = [String]()
  static var shortestCount = 0
  static var userID = UUID().uuidString
  
  // Index of array in 2d array, u can see it in scoreSwitch method
  static var index = 0
}
