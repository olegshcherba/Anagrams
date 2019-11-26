//
//  SettingsTableVC.swift
//  Anagrams
//
//  Created by MultisAudios on 04.09.2018.
//  Copyright © 2018 MultisAudios. All rights reserved.
//

import UIKit
import FirebaseDatabase
import ChameleonFramework

class SettingsTableVC: UITableViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var selectionBarButtonItem: UIBarButtonItem!
  
  // MARK: - Instance properties
  
  var gameEngine = GameEngine()
  
  // MARK: - @IBActions
  
  @IBAction func selectionBarButtonItemPressed(_ sender: Any) {
    var checkedCount = 0
    for category in GameBase.categoryNames {
      if category.checked {
        checkedCount += 1
      }
    }
    if checkedCount < GameBase.categoryNames.count {
      for category in  GameBase.categoryNames {
        category.checked = true
        selectionBarButtonItem.title = "Deselect All"
      }
    } else {
      for category in  GameBase.categoryNames {
        category.checked = false
        selectionBarButtonItem.title = "Select All"
      }
    }
    tableView.reloadData()
  }
  
  // MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureSettingsTableVCUIElements()
    self.navigationItem.largeTitleDisplayMode = .never
    self.navigationItem.largeTitleDisplayMode = .always
    if #available(iOS 13.0, *) {
    overrideUserInterfaceStyle = .light
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    GameBase.categoryChecked = []
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if self.isMovingFromParent {
      GameBase.wordsArr = []
      getCheckedCategories()
      gameEngine.array2DRefill()
    }
  }
  
  // MARK: - Table view data source & delegate
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return GameBase.categoryNames.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.tintColor = UIColor(hexString: "#1f5e54")
    let category = GameBase.categoryNames[indexPath.row]
    configureText(for: cell, with: category)
    configureCheckmark(for: cell, with: category)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.backgroundColor = UIColor(white: 1, alpha: 0.5)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let cell = tableView.cellForRow(at: indexPath) {
      let category = GameBase.categoryNames[indexPath.row]
      category.toggleChecked()
      configureCheckmark(for: cell, with: category)
      configureText(for: cell,
                    with: category)
      configureSelectionTitle()
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.1
  }

  // MARK: - Additional methods
  
  //Configure checkmark
  func configureCheckmark(for cell: UITableViewCell,
                          with category: Category) {
    if category.checked {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
  }
  
  // Title of selection bar button item
  func configureSelectionTitle() {
    var checkedCount = 0
    for category in GameBase.categoryNames {
      if category.checked {
        checkedCount += 1
      }
    }
    if checkedCount < GameBase.categoryNames.count {
      selectionBarButtonItem.title = "Select All"
    } else {
      selectionBarButtonItem.title = "Deselect All"
    }
  }
  
  // Configure labels
  func configureText(for cell: UITableViewCell,
                     with category: Category) {
    let categoryLabel = cell.viewWithTag(1000) as! UILabel
    let categoryCountLabel = cell.viewWithTag(1001) as! UILabel
    let difficultyLabel = cell.viewWithTag(1002) as! UILabel
    let imageView = cell.viewWithTag(1004) as! UIImageView
    categoryLabel.text = category.name
    categoryCountLabel.text = "\(gameEngine.getPlistCount(plistName: category.name))"
    difficultyLabel.text = "\(String(describing: category.difficulty))"
    imageView.image = UIImage(named: "\(category.name).png")
  
    switch category.difficulty {
    case .easy:
      difficultyLabel.textColor = UIColor.flatGreen()
    case .medium:
      difficultyLabel.textColor = UIColor.flatOrange()
    case .hard:
      difficultyLabel.textColor = UIColor.flatRed()
    }
  }
  
  func getCheckedCategories() {
    GameBase.categoryChecked = []
    for category in GameBase.categoryNames {
      if category.checked {
        GameBase.categoryChecked.append(category.name)
      }
    }
  }
  
  //MARK: - Cofigure UI Elements
  
  func configureSettingsTableVCUIElements() {
    self.navigationItem.rightBarButtonItem?.tintColor = UIColor.flatWhite()
    let backgroundImage = UIImage(named: "Settings.jpg")
    let imageView = UIImageView(image: backgroundImage)
    self.tableView.backgroundView = imageView
    self.tableView.backgroundView?.contentMode = .scaleAspectFill
    let blurEffect = UIBlurEffect(style: .light)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame = imageView.bounds
    imageView.addSubview(blurView)
  }
}
