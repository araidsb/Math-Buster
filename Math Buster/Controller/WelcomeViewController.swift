//
//  WelcomeViewController.swift
//  Math Buster
//
//  Created by Арай Дуйсебекова on 24.04.2023.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: [UserScoreSection] = [] {
        didSet {
            print("Value of variable 'dataSource' was changed")
            tableView.reloadData()
        }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.register(UINib(nibName: "ScoreTableViewCell", bundle: nil), forCellReuseIdentifier: ScoreTableViewCell.identifier)
        tableView.dataSource = self
//        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(getUserScore), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getUserScore()
    }
    @objc
    func getUserScore() {
        tableView.refreshControl?.endRefreshing()
        
        var easyScoreList = ViewController.getAllUsersScores(level: .easy)
        easyScoreList.sort { userScore1, userScore2 in
            return userScore1.score > userScore2.score
        }
        let easySection = UserScoreSection.init(list: easyScoreList, title: "Easy")
        
        var mediumScoreList = ViewController.getAllUsersScores(level: .medium)
        mediumScoreList.sort { userScore1, userScore2 in
            return userScore1.score > userScore2.score
        }
        let mediumSection = UserScoreSection.init(list: mediumScoreList, title: "Medium")
        
        var hardScoreList = ViewController.getAllUsersScores(level: .hard)
        hardScoreList.sort { userScore1, userScore2 in
            return userScore1.score > userScore2.score
        }
        let hardSection = UserScoreSection.init(list: hardScoreList, title: "Hard")
        
        self.dataSource = [easySection,mediumSection,hardSection]
        
        
        }
    func getSingleUserText(indexPath: IndexPath) -> String? {
        let userScore: UserScore = dataSource[indexPath.section].list[indexPath.row]
        let text = "Name: \(userScore.name), Score: \(userScore.score)"
        return text
    }
    
    func swipeToDelete(indexPath: IndexPath) {
        let userScore: UserScore = dataSource[indexPath.section].list[indexPath.row]

        tableView.reloadData()
    }
}
// MARK: UITableViewDataSource, UITableViewDelegate
extension WelcomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScoreTableViewCell.identifier, for: indexPath) as! ScoreTableViewCell
        
        cell.scoreTextLabel.text = getSingleUserText(indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController = ScoreDetailViewController()
        
        viewController.text = getSingleUserText(indexPath: indexPath)
        navigationController?.pushViewController(viewController, animated: true)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].title
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            swipeToDelete(at: indexPath.row)
            tableView.reloadData()
        }
    }
}
    
    

struct UserScoreSection {
    let list: [UserScore]
    let title: String
}
