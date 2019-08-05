//
//  GameEngine.swift
//  Anagrams
//
//  Created by MultisAudios on 05.10.2018.
//  Copyright © 2018 MultisAudios. All rights reserved.
//

import Foundation

class GameEngine {
  
  // MARK: - Sorting array of strings and creating 2d array
  
  func sorting(array: [String]) -> [Array<String>] {
    var array2D = [Array<String>]()
    
    let sortedWords = array.sorted { p0, p1 in
      return p0.count == p1.count ? p0 < p1 : p0.count < p1.count
    }
    
    let sectionsCount = (sortedWords.last?.count)! - (sortedWords.first?.count)!
    for _ in 0...sectionsCount {
      let sectionArray = [String]()
      array2D.append(sectionArray)
    }
    
    for word in sortedWords {
      array2D[word.count - sortedWords.first!.count].append(word)
    }
    return array2D
  }
  
  // MARK: - Getting data from plists
  
  // filling GameBase.wordsArr from plist
  func readPlist(plistName: String){
    var words = [String]()
    if let path = Bundle.main.path(forResource: plistName, ofType: "plist") {
      if let arrayOfDicts = NSArray(contentsOfFile: path) {
        for dict in arrayOfDicts {
          for (_, value) in dict as! NSDictionary {
            words.append(value as! String)
          }
        }
        for word in words {
          GameBase.wordsArr.append(word.lowercased())
        }
      }
    }
  }
  
  func getPlistCount(plistName: String) -> Int {
    var words = [String]()
    if let path = Bundle.main.path(forResource: plistName, ofType: "plist") {
      if let arrayOfDicts = NSArray(contentsOfFile: path) {
        for dict in arrayOfDicts {
          for (_, value) in dict as! NSDictionary {
            words.append(value as! String)
          }
        }
      }
    }
    return words.count
  }
  
  func readCategoryNames(plistName: String) {
    GameBase.categoryNames = [Category]()
    if let URL = Bundle.main.url(forResource: plistName, withExtension: "plist") {
      if let categoriesFromPlist = NSArray(contentsOf: URL) {
        for categoryFromPlist in categoriesFromPlist {
          let category = Category()
          category.name = (categoryFromPlist as! NSDictionary).value(forKey: "name") as! String
          category.difficulty = Category.Difficulty(rawValue: (categoryFromPlist as! NSDictionary).value(forKey: "difficultyLevel") as! Int)!
          GameBase.categoryNames.append(category)
        }
      }
    }
  }
  
  // Filling the 2d Array
  func array2DRefill() {
    if GameBase.categoryChecked.isEmpty {
      readPlist(plistName: ((GameBase.categoryNames.first?.name)!))
    } else {
      for anyChecked in GameBase.categoryChecked {
        let name = anyChecked
        readPlist(plistName: name)
      }
    }
    GameBase.words2D = [Array<String>]()
    GameBase.words2D = sorting(array: GameBase.wordsArr)
    GameBase.shortestCount = (GameBase.words2D.first?[0].count)!
  }
  
  // MARK: - Anagram making code
  
  func makeAnagram(array: Array<String>) -> String {
    var shuffledChars = [Character]()
    var shuffledStr = String()
    
    if let randomElement = array.randomElement() {
      repeat {
        shuffledChars = randomElement.shuffled()
        shuffledStr = String(shuffledChars)
      } while (shuffledStr == randomElement)
    }
    return shuffledStr
  }
  
  // MARK: - Local saving and loading of scores
  
  func documentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
  func dataFilePath() -> URL {
    return documentsDirectory().appendingPathComponent("Scores.plist")
  }
  
  func saveLocalScores() {
    let encoder = PropertyListEncoder()
    do {
      let data = try encoder.encode(GameBase.scoresArray)
      try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
    } catch {
      print("Error encoding array of scores!")
    }
  }
  
  func loadLocalScores() {
    let path = dataFilePath()
    if let data = try? Data(contentsOf: path) {
      let decoder = PropertyListDecoder()
      do {
        GameBase.scoresArray = try decoder.decode([Int].self, from: data)
      } catch {
        print("Error decoding scores array!")
      }
    }
  }
}
