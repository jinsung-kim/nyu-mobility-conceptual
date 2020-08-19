//
//  StartingController.swift
//  NYU Mobility 2
//
//  Created by Jin Kim on 8/17/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit

class StartingController: UIViewController {
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        logoutButton()
        tutorialButton()
        createCircleView()
        
        // Hide back button -> Since logout button will be there
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func unwindToRecorder(_ sender: UIStoryboardSegue) {}
    
    // Set logout button
    func logoutButton() {
        let instructionButton = UIBarButtonItem()
        instructionButton.title = "Logout"
        instructionButton.action = #selector(logoutTap)
        instructionButton.target = self
        navigationItem.leftBarButtonItem = instructionButton
    }
    
    @objc func logoutTap() {
        save("name", "")
        save("email", "")
        save("password", "")
        performSegue(withIdentifier: "Logout", sender: self)
    }
    
    func tutorialButton() {
        let tutorialButton = UIBarButtonItem()
        tutorialButton.title = "See Tutorial"
        tutorialButton.action = #selector(tutorialTap)
        tutorialButton.target = self
        navigationItem.rightBarButtonItem = tutorialButton
    }
    
    @objc func tutorialTap() {
        performSegue(withIdentifier: "Tutorial", sender: self)
    }
    
    func createCircleView() {
        circleView.layer.cornerRadius = 120 // half the width / height (of the view)
        circleView.backgroundColor = Colors.nyuBackground
    }
    
    @IBAction func startClicked(_ sender: Any) {
        performSegue(withIdentifier: "Started", sender: self)
    }
    
    func save(_ key: String, _ value: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: "\(key)")
    }
}
