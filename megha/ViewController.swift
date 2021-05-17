//
//  ViewController.swift
//  megha
//
//  Created by Karthikeyan K on 17/05/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var buttonOutput: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        print("View Tapped", sender)
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        print("Button Tapped", sender)
    }
    
}
