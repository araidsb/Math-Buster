//
//  ViewController.swift
//  Math Buster
//
//  Created by Арай Дуйсебекова on 11.04.2023.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var problemLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timerContainerView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var resultTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var dataModel: viewControllerDataModel = viewControllerDataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
        generateProblem()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataModel.navigationBarPreviousColor = navigationController?.navigationBar.tintColor
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scheduleTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.tintColor = dataModel.navigationBarPreviousColor
    }
    
    func setupUI() {
        
        self.title = "Math Buster"
        timerContainerView.layer.cornerRadius = 5
        resultTextField.keyboardType = .decimalPad
    }
    
    func generateProblem() {
        
        let selectedIndex = segmentControl.selectedSegmentIndex
        let range = dataModel.ranges[selectedIndex]
        
        let firstDigit = Int.random(in: range)
        let arithmeticOperator: String = ["+", "-", "/", "x"].randomElement()!
        
        var startingDigit: Int = range.lowerBound
        var endingDigit: Int = range.upperBound
        if arithmeticOperator == "/" && startingDigit == 0{
            startingDigit = 1
        } else if arithmeticOperator == "-" {
            endingDigit = firstDigit
        }
                    
        let secondDigit = Int.random(in: startingDigit...endingDigit)
        
        problemLabel.text = "\(firstDigit) \(arithmeticOperator) \(secondDigit) ="
        
        switch arithmeticOperator {
        case "+":
            dataModel.result = Double(firstDigit + secondDigit)
        case "-":
            dataModel.result = Double(firstDigit - secondDigit)
        case "x":
            dataModel.result = Double(firstDigit * secondDigit)
        case "/":
            dataModel.result  = Double(firstDigit) / Double(secondDigit)
        default:
            dataModel.result = nil
        }
    }
    
    func scheduleTimer() {
        dataModel.countDown = 30
        dataModel.timer?.invalidate()
        dataModel.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerUI), userInfo: nil, repeats: true)
    }
    @objc
    func updateTimerUI() {
        dataModel.countDown -= 1
        
        timeLabel.text = String(format: "00:%02d", dataModel.countDown)
        progressView.progress = Float(30 - dataModel.countDown) / 30
        
        print("progressView.progress : \(progressView.progress)")
        
        if dataModel.countDown <= 0 {
            
           finishTheGame()
            
        }
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        guard let text = resultTextField.text else {
            print("Text is nil")
            return
        }
        guard !text.isEmpty else {
            print("Text is empty")
            return
        }
        
        guard let newResult = Double(text) else {
            print("Couldn't convert \(text) to Double")
            return
        }
        
        if newResult == dataModel.result {
            let selectedIndex = segmentControl.selectedSegmentIndex
            dataModel.score += dataModel.scoreAmount[selectedIndex]
            print("Correct answer")
            scoreLabel.text = "Score: \(dataModel.score)"
        } else {
            print("Incorrect answer")
        }
        
        generateProblem()
        resultTextField.text = nil
    }
    
    
    
    
    @IBAction func restartTapped(_ sender: Any) {
       restart()
        	
    }
    
    func restart () {
        dataModel.score = 0
        scoreLabel.text = "Score: 0"
        
        generateProblem()
        scheduleTimer()
        
        resultTextField.isEnabled = true
        submitButton.isEnabled = true
            
    }
            
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
       restart()
    }
    
    func finishTheGame() {
        dataModel.timer?.invalidate()
        resultTextField.isEnabled = false
        submitButton.isEnabled = false
        
        askForName()
    }
    
    func askForName(){
        let alertController = UIAlertController(title: "Game is Over!", message: "Save your score: \(dataModel.score)", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter your name"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alertController.textFields?.first else {
                print("Textfield is absent")
                return
            }
            guard let text = textField.text, !text.isEmpty else {
                print("Text is nil or empty")
                return
            }
            
            print("Name: \(text)")
            
//            self.saveUserScore(name: text)
            self.saveUSerScoreAsStruct(name: text)
        }
        alertController.addAction(saveAction)
        
//        let skipAction = UIAlertAction(title: "Skip", style: .destructive)
//        alertController.addAction(skipAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
        
    }
    
    func saveUSerScoreAsStruct(name: String) {
        let userScore: UserScore = UserScore(name: name, score: dataModel.score)
        
        var level: Level?
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            level = .easy
        case 1:
            level = .medium
        case 2:
            level = .hard
        default:
            ()
        }
        
        guard let level = level else {
            print("Level is nil because index put of [0, 1, 2]")
            return
        }
        
        let userScoreArray: [UserScore] = ViewController.getAllUsersScores(level: level) + [userScore]
        
        
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(userScoreArray)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: level.key())

            
        } catch {
            print("Couldn't decode given data to [UserScore] with error: \(error.localizedDescription)")
        }
    }
    
    static func getAllUsersScores(level: Level) -> [UserScore] {
        var result: [UserScore] = []
        
        let usersDefaults = UserDefaults.standard
        if let data = usersDefaults.object(forKey: level.key()) as? Data
            {
            
            do {
                let decoder = JSONDecoder()
                result = try decoder.decode([UserScore].self, from: data)
            } catch {
                print("Couldn't decode given data to [UserScore] with error: \(error.localizedDescription)")
            }
            
        }
        return result
    }
    
    func saveUserScore(name: String) {
        let userScore: [String: Any] = ["name": name, "score": dataModel.score]
        let userScoreArray: [[String: Any]] = getUserScoreArray() + [userScore]
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(userScoreArray, forKey: viewControllerDataModel.userScoreKey)
    }
    
    func getUserScoreArray() -> [[String: Any]] {
        let userDefaults = UserDefaults.standard
        let array = userDefaults.array(forKey: viewControllerDataModel.userScoreKey) as? [[String: Any]]
        return array ?? []
    }
}


struct viewControllerDataModel {
    
    var timer: Timer?
    var countDown: Int =  30
    var result: Double?
    var score: Int = 0
    let ranges = [0...9, 10...99, 100...999]
    var scoreAmount = [1, 2, 3]
    
    var navigationBarPreviousColor: UIColor?
    
    static let userScoreKey: String = "userScore"
    
}

struct UserScore: Codable {
    let name: String
    let score: Int
}

enum Level: String {
    case easy
    case medium
    case hard
    
    func key() -> String {
        switch self {
        case.easy:
            return "esyUserScore"
        case.medium:
            return "mediumUserScore"
        case.hard:
            return "hardUserScore"
        }
    }
}
