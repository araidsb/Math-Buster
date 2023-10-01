//
//  ScoreDetailViewController.swift
//  Math Buster
//
//  Created by Арай Дуйсебекова on 02.05.2023.
//

import UIKit

class ScoreDetailViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textLabel.text = text
    }


    @IBAction func goBackButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
