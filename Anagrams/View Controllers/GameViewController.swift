//
//  ViewController.swift
//  Anagrams
//
//  Created by MultisAudios on 18.08.2018.
//  Copyright © 2018 MultisAudios. All rights reserved.
//

import UIKit
import NotificationCenter
import FirebaseDatabase
import ChameleonFramework

class GameViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var anagramLabel: UILabel!
  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var answerLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var restartButton: UIButton!
  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var life1ImageView: UIImageView!
  @IBOutlet weak var life2ImageView: UIImageView!
  @IBOutlet weak var life3ImageView: UIImageView!
  @IBOutlet weak var scoreBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var skipBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var restartBottomConstraint: NSLayoutConstraint!
  
  // MARK: - Instance properties
  
  var gameEngine = GameEngine()
  var ref: DatabaseReference?
  var textIsEnabled: Bool!
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - IBActions
  
  @IBAction func textFieldChanged(_ sender: UITextField) {
    matching()
  }
  
  @IBAction func restartPressed(_ sender: UIButton) {
    GameBase.wordsArr = []
    restart()
  }
  
  @IBAction func skipPressed(_ sender: UIButton) {
    let anagramSorted = String((anagramLabel.text!).lowercased().sorted())
    var arraySorted = [String]()
    for word in GameBase.words2D[(anagramLabel.text?.count)! - (GameBase.shortestCount)] {
      arraySorted.append(String(word.lowercased().sorted()))
    }
    // Removing skipped word from 2d array
    if let index = arraySorted.firstIndex(of: "\(anagramSorted)") {
      GameBase.words2D[(anagramLabel.text?.count)! - (GameBase.shortestCount)].remove(at: index)
    }
    
    if GameBase.score > 0 {
      GameBase.score -= 1
    } else if GameBase.score == 0 {
      GameBase.lives -= 1
      updateLivesAndButtons()
    }
    
    scoreLabel.text = "Score: \(GameBase.score)"
    updateLivesAndButtons()
    
    if GameBase.lives <= 0 {
      gameOver()
    } else {
      scoreSwitch()
    }
  }
  
  // MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureGameViewControllerUIElements()
    setLifeImages()
    updateLivesAndButtons()
    gameEngine.loadLocalScores()
    ref = Database.database().reference()
    textField.autocorrectionType = .no
    startGame()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
  }
  
  // Filling 2d array from scratch when back bar button item pressed
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if self.isMovingFromParent {
      GameBase.words2D = [Array<String>]()
      gameEngine.array2DRefill()
    }
  }
  
  // MARK: - Additional methods
  
  // MARK: - Show next anagram
  
  func scoreSwitch() {
    GameBase.index = GameBase.score / 5
    nextWord()
  }
  
  func nextWord() {
    if GameBase.words2D[GameBase.index].isEmpty {
      if GameBase.words2D[GameBase.index] == GameBase.words2D[GameBase.words2D.count - 1] {
        wordsOut()
      } else {
        GameBase.index += 1
        nextWord()
      }
    } else {
      let anagram = gameEngine.makeAnagram(array: GameBase.words2D[GameBase.index])
      anagramLabel.text = anagram
    }
  }
  
  // MARK: - Timer functionality
  
  func runTimer() {
    GameBase.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(GameViewController.updateTimer)), userInfo: nil, repeats: true)
    
    GameBase.seconds = 60
  }
  
  @objc func updateTimer() {
    GameBase.seconds -= 1
    timerColor()
    timerLabel.text = String(GameBase.seconds)
    if GameBase.seconds == 0 {
      gameOver()
    }
  }
  
  func timerColor() {
    switch GameBase.seconds {
    case 11...20:
      timerLabel.textColor = UIColor.flatOrange
    case 0...10:
      timerLabel.textColor = UIColor.flatRed
    default:
      timerLabel.textColor = UIColor.flatBlack
    }
  }
  
  // MARK: - Start game and game over code
  
  // Start game code
  func startGame() {
    GameBase.timer.invalidate()
    timerLabel.text = "60"
    timerLabel.textColor = UIColor.black
    self.ref?.observeSingleEvent(of: .value, with: { (snapshot) in
      if !snapshot.hasChild("Scores/\(GameBase.userID)") {
        self.textIsEnabled = true
      } else {
        self.textIsEnabled = false
      }
    })
    runTimer()
    textField.isEnabled = true
    textField.becomeFirstResponder()
    GameBase.lives = 3
    GameBase.score = 0
    scoreLabel.text = "Score: \(GameBase.score)"
    restartButton.isHidden = true
    skipButton.isEnabled = true
    textField.text = ""
    answerLabel.text = ""
    updateLivesAndButtons()
    scoreSwitch()
  }
  
  // Game over code
  func gameOver() {
    GameBase.timer.invalidate()
    answerLabel.text = "Game Over"
    restartButton.isHidden = false
    skipButton.isEnabled = false
    skipButton.isHidden = true
    textField.isEnabled = false
    saveLocalAndOnServer()
  }
  
  // Words out code
  func wordsOut() {
    GameBase.timer.invalidate()
    answerLabel.text = "Run out of words"
    textField.isEnabled = false
    restartButton.isHidden = false
    skipButton.isEnabled = false
    saveLocalAndOnServer()
  }
  
  // When restart pressed code
  func restart() {
    if GameBase.seconds > 0 {
      GameBase.lives = 0
      updateLivesAndButtons()
      gameOver()
      self.restartButton.isHidden = true
      GameBase.words2D = [Array<String>]()
      self.gameEngine.array2DRefill()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
        self.startGame()
      })
    } else {
      gameOver()
      restartButton.isHidden = true
      GameBase.words2D = [Array<String>]()
      gameEngine.array2DRefill()
      startGame()
    }
  }
  
  // MARK: - Check anagram for matching with word
  
  // When the word is guessed
  func matching() {
    if GameBase.wordsArr.contains(textField.text!.lowercased()) && anagramLabel.text!.lowercased().sorted() == textField.text?.lowercased().sorted() {
      GameBase.score += 1
      GameBase.seconds += 5
      updateTimer()
      GameBase.words2D[(textField.text?.count)! - (GameBase.shortestCount)].removeAll { $0 == "\(textField.text!)" }
      textField.text = ""
      scoreLabel.text = "Score: \(GameBase.score)"
      updateLivesAndButtons()
      scoreSwitch()
    }
  }
  
  // MARK: - Call local saving func and save record on server
  
  func saveLocalAndOnServer() {
    if GameBase.score > 0 && GameBase.score > GameBase.scoresArray.max()! {
      var title = ""
      
      // TODO: - change local to firebase check
      
      if GameBase.scoresArray.max() == 0 {
        title = "FIRST RECORD!"
      } else {
        title = "NEW RECORD!"
      }
      
      GameBase.scoresArray.append(GameBase.score)
      gameEngine.saveLocalScores()
      
      let alertController = UIAlertController(title: title, message: "Would you like to save your score to server?", preferredStyle: .alert)
      
      let okAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        self.ref?.observeSingleEvent(of: .value, with: { (snapshot) in
          if !snapshot.hasChild("Scores/\(GameBase.userID)") {
            let key = self.ref?.child("Scores").child(GameBase.userID).key
            let user = ["Name": alertController.textFields![0].text as! String, "Score": GameBase.score, "UserID": GameBase.userID as String] as [String : Any]
            self.ref?.child("Scores").child(key!).setValue(user)
          } else {
            let childUpdate = ["Score": GameBase.score]
            self.ref?.child("Scores").child(GameBase.userID).updateChildValues(childUpdate)
          }
        })
        self.performSegue(withIdentifier: "ModalToScoreboardTableVC", sender: self)
      }
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
      }
      
      alertController.addAction(okAction)
      okAction.isEnabled = false
      alertController.addAction(cancelAction)
      
      if self.textIsEnabled == true {
        alertController.addTextField { (textField) in
          textField.textAlignment = .center
          textField.placeholder = "Enter your name"
          NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using: {_ in
            let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
            okAction.isEnabled = textCount > 0
          })
        }
      } else {
        okAction.isEnabled = true
      }
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  // MARK: - Update life image views and buttons visibility
  
  // Prepare life image views for changing image color
  func setLifeImages() {
    life1ImageView.image = life1ImageView.image?.withRenderingMode(.alwaysTemplate)
    life2ImageView.image = life2ImageView.image?.withRenderingMode(.alwaysTemplate)
    life3ImageView.image = life3ImageView.image?.withRenderingMode(.alwaysTemplate)
  }
  
  // Set images and button skipOrRestart title
  func updateLivesAndButtons() {
    switch GameBase.lives {
    case 2:
      life3ImageView.tintColor = .flatWhiteDark
    case 1:
      life2ImageView.tintColor = .flatWhiteDark
      life3ImageView.tintColor = .flatWhiteDark
      
      if GameBase.score == 0 {
        skipButton.isHidden = true
        restartButton.isHidden = false
      } else {
        skipButton.isHidden = false
        restartButton.isHidden = true
      }
      
    case 0:
      life1ImageView.tintColor = .flatWhiteDark
      life2ImageView.tintColor = .flatWhiteDark
      life3ImageView.tintColor = .flatWhiteDark
      
    default:
      life3ImageView.tintColor = UIColor(hexString: "#1f5e54")
      life2ImageView.tintColor = UIColor(hexString: "#1f5e54")
      life1ImageView.tintColor = UIColor(hexString: "#1f5e54")
      skipButton.isHidden = false
      restartButton.isHidden = true
    }
  }
  
  // MARK: - Get keyboard height & set bottom constraints for buttons
  
  @objc func keyboardWillShow(notification: Notification) {
    let userInfo:NSDictionary = notification.userInfo! as NSDictionary
    let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
    let keyboardRectangle = keyboardFrame.cgRectValue
    let keyboardHeight = keyboardRectangle.height
    scoreBottomConstraint.constant = keyboardHeight + 12
    skipBottomConstraint.constant = keyboardHeight + 6
    restartBottomConstraint.constant = keyboardHeight + 6
  }
  
  // MARK: - Configure UI elements
  
  func configureGameViewControllerUIElements() {
    restartButton.tintColor = UIColor(hexString: "#1f5e54")
    skipButton.tintColor = UIColor(hexString: "#1f5e54")
    self.view.backgroundColor = .flatWhite
    let backgroundImage = UIImage(named: "Settings.jpg")
    let imageView = UIImageView(image: backgroundImage)
    imageView.frame = view.bounds
    view.addSubview(imageView)
    view.sendSubviewToBack(imageView)
    view.contentMode = .scaleAspectFit
    let blurEffect = UIBlurEffect(style: .light)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame = imageView.bounds
    imageView.addSubview(blurView)
  }
}
