//
//  MenuViewController.swift
//  Anagrams
//
//  Created by MultisAudios on 04.09.2018.
//  Copyright © 2018 MultisAudios. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

class MenuViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var settingsButton: UIButton!
  @IBOutlet weak var scoreboardButton: UIButton!
  
  // MARK: - Instance properties
  
  let gameEngine = GameEngine()
  
  // MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureMenuVCUIElements()
    gameEngine.readCategoryNames(plistName: "Categories")
    gameEngine.array2DRefill()
    
    // TODO: - changes here load and save best score to keychain???
    
    if (KeychainWrapper.standard.string(forKey: "userID") == nil) {
      KeychainWrapper.standard.set(GameBase.userID, forKey: "userID")
    } else {
      GameBase.userID = (KeychainWrapper.standard.string(forKey: "userID"))!
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }
  
  // MARK: - Segue
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let backItem = UIBarButtonItem()
    backItem.tintColor = .flatWhite()
    navigationController?.navigationBar.barStyle = .black
    navigationItem.backBarButtonItem = backItem
    
    // Set titles of back button
    if segue.identifier == "ShowGameVC" {
      backItem.title = "Menu"
    } else {
      backItem.title = "Back"
    }
  }
  
  // MARK: - Configure UI elements
  
  func configureMenuVCUIElements() {
    navigationController?.navigationBar.barTintColor = UIColor(hexString: "#1f5e54")
    view.backgroundColor = UIColor(patternImage: UIImage(named: "Menu1.jpg")!)
    playButton.contentEdgeInsets.left = 15
    playButton.contentEdgeInsets.right = 15
    playButton.tintColor = .flatBlack()
    playButton.backgroundColor = .flatSand()
    playButton.layer.cornerRadius = 10
    playButton.layer.borderWidth = 1
    playButton.layer.borderColor = UIColor.flatCoffeeDark().cgColor
    settingsButton.contentEdgeInsets.left = 15
    settingsButton.contentEdgeInsets.right = 15
    settingsButton.layer.cornerRadius = 10
    settingsButton.tintColor = .flatBlack()
    settingsButton.backgroundColor = .flatSand()
    settingsButton.layer.borderWidth = 1
    settingsButton.layer.borderColor = UIColor.flatCoffeeDark().cgColor
    scoreboardButton.contentEdgeInsets.left = 15
    scoreboardButton.contentEdgeInsets.right = 15
    scoreboardButton.layer.cornerRadius = 10
    scoreboardButton.tintColor = .flatBlack()
    scoreboardButton.backgroundColor = .flatSand()
    scoreboardButton.layer.borderWidth = 1
    scoreboardButton.layer.borderColor = UIColor.flatCoffeeDark().cgColor
  }
}
