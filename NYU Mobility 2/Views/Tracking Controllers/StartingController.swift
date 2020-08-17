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
        logoutButton()
        createCircleView()
        
        // Hide back button -> Since logout button will handle that case
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
    }
    
    // Set logout button
    func logoutButton() {
        let instructionButton = UIBarButtonItem()
        instructionButton.title = "Logout"
        instructionButton.action = #selector(logoutTap)
        instructionButton.target = self
        navigationItem.rightBarButtonItem = instructionButton
    }
    
    @objc func logoutTap() {
        save("name", "")
        save("email", "")
        save("password", "")
        performSegue(withIdentifier: "Logout", sender: self)
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
