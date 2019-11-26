//
//  ScoreboardTableVC.swift
//  Anagrams
//
//  Created by MultisAudios on 6/15/19.
//  Copyright © 2019 MultisAudios. All rights reserved.
//

import UIKit
import NotificationCenter
import FirebaseDatabase
import Network
import SVProgressHUD
import ChameleonFramework

@available(iOS 12.0, *)
@available(iOS 12.0, *)

class ScoreboardTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - Instance properties
  
  var usersList = [UserModel]()
  var ref: DatabaseReference?
  let monitor = NWPathMonitor()
  var highlightedRow = 0
  var isModal: Bool {
    return self.presentingViewController?.presentedViewController == self
      || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
      || self.tabBarController?.presentingViewController is UITabBarController
  }
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - Actions
  
  @objc func cancelTapped() {
    self.dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if #available(iOS 13.0, *) {
      overrideUserInterfaceStyle = .light
    }
    tableView.dataSource = self
    tableView.delegate = self
    configureScoreboardTableVCUIElements()
    self.navigationItem.largeTitleDisplayMode = .never
    self.navigationItem.largeTitleDisplayMode = .always
    tableView.tableFooterView = UIView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    cancelButtonIfVCModal()
    SVProgressHUD.show(withStatus: "")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.checkInternetAndGetData()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    monitor.cancel()
    removeProgressHud()
  }
  
  // MARK: - Table view data source
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 1 {
      return usersList.count
    } else {
      return 1
    }
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.alpha = 0.8
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
    if indexPath.section == 1 {
      let user = self.usersList[indexPath.row]
      self.configureSection1Text(for: cell, with: user, at: indexPath)
      self.configureCellColor(for: cell, with: user, at: indexPath)
    } else {
      cell.backgroundColor = .flatWhite()
      configureSection0Text(for: cell)
    }
    return cell
  }
  
  // MARK: - Additional methods
  
  // Configure Cell background color
  func configureCellColor(for cell: UITableViewCell, with user: UserModel, at indexPath: IndexPath) {
    if user.userID == GameBase.userID {
      cell.self.backgroundColor = UIColor(hexString: "#1f5e54")
    } else {
      cell.self.backgroundColor = .flatWhite()
    }
  }
  
  // Configure Cell text
  func configureSection1Text(for cell: UITableViewCell,
                             with user: UserModel, at indexPath: IndexPath) {
    let placeLabel = cell.viewWithTag(1001) as! UILabel
    let nameLabel = cell.viewWithTag(1002) as! UILabel
    let scoreLabel = cell.viewWithTag(1003) as! UILabel
    nameLabel.text = user.name
    scoreLabel.text = "\(String(user.score))    "
    placeLabel.text = "   \(String(indexPath.row + 1))"
    nameLabel.font = .systemFont(ofSize: 19)
    scoreLabel.font = .systemFont(ofSize: 19)
    placeLabel.font = .systemFont(ofSize: 19)
  }
  
  func configureSection0Text(for cell: UITableViewCell) {
    let placeLabel = cell.viewWithTag(1001) as! UILabel
    let nameLabel = cell.viewWithTag(1002) as! UILabel
    let scoreLabel = cell.viewWithTag(1003) as! UILabel
    nameLabel.text = "Name"
    scoreLabel.text = "Score"
    placeLabel.text = "Place"
    nameLabel.textColor = UIColor.black
    scoreLabel.textColor = UIColor.black
    placeLabel.textColor = UIColor.black
    nameLabel.font = .boldSystemFont(ofSize: 20)
    scoreLabel.font = .boldSystemFont(ofSize: 20)
    placeLabel.font = .boldSystemFont(ofSize: 20)
  }
  
  // MARK: - Check internet connection and load data from Firebase
  
  func checkInternetAndGetData() {
    monitor.pathUpdateHandler = { path in
      if path.status != .satisfied {
        SVProgressHUD.show(withStatus: "Waiting for network...")
      } else {
        self.getScoresFromServer()
      }
    }
    let queue = DispatchQueue(label: "Monitor")
    monitor.start(queue: queue)
  }
  
  // Get scores from Firebase
  func getScoresFromServer() {
    ref = Database.database().reference().child("Scores")
    ref?.observe(DataEventType.value, with: { (snapshot) in
      if snapshot.childrenCount > 0 {
        self.usersList.removeAll()
        for scores in snapshot.children.allObjects as! [DataSnapshot] {
          let scoreObject = scores.value as? [String: AnyObject]
          let name = scoreObject?["Name"]
          let score = scoreObject?["Score"]
          let userID = scoreObject?["UserID"]
          let user = UserModel(name: (name as! String), score: (score as! Int), userID: (userID as! String))
          self.usersList.append(user)
        }
        self.usersList.sort(by: { $0.score > $1.score })
        
        var index = 0
        for user in self.usersList {
          index += 1
          if user.userID == GameBase.userID {
            self.highlightedRow = index - 1
          }
          if self.usersList.count > 0 {
            self.monitor.cancel()
            self.removeProgressHud()
          }
        }
        UIView.transition(with: self.tableView, duration: 0.4, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
        
        if self.highlightedRow != 0 {
          self.scrollToUser()
        }
      }
    })
  }
  
  // MARK: - remove SVProogressHUD
  
  func removeProgressHud() {
    DispatchQueue.main.async {
      SVProgressHUD.dismiss()
    }
  }
  
  // MARK: - Add "Cancel" left bar button item if VC is presented modally
  
  func cancelButtonIfVCModal() {
    if isModal {
      navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelTapped))
      navigationController?.navigationBar.backgroundColor = UIColor(hexString: "#1f5e54")
      navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelTapped))
      navigationItem.leftBarButtonItem?.tintColor = .flatWhite()
    }
  }
  
  // MARK: - Configure UI elements
  
  func configureScoreboardTableVCUIElements() {
    navigationController?.navigationBar.barStyle = .black
    navigationController?.navigationBar.barTintColor = UIColor(hexString: "#1f5e54")
    self.title = "Scoreboard"
    SVProgressHUD.setRingRadius(18)
    SVProgressHUD.setBackgroundColor(.clear)
    SVProgressHUD.setFont(.systemFont(ofSize: 18))
    SVProgressHUD.setRingThickness(3)
    SVProgressHUD.setForegroundColor(UIColor(hexString: "#1f5e54")!)
    let backgroundImage = UIImage(named: "Settings.jpg")
    let imageView = UIImageView(image: backgroundImage)
    self.tableView.backgroundView = imageView
    self.tableView.backgroundView?.contentMode = .scaleAspectFill
    let blurEffect = UIBlurEffect(style: .light)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame = imageView.bounds
    imageView.addSubview(blurView)
  }
  
  func scrollToUser() {
    let indexPath = IndexPath(row: highlightedRow, section: 1)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
      self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
  }
}
