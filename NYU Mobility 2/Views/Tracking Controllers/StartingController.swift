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
        tutorialButton()
        createCircleView()
        
        // Ask email if there isn't already an email entered
        if (UserDefaults.standard.string(forKey: "email")! == "") {
            showInputDialog(title: "Enter your email",
                            subtitle: "Your email is needed to label files",
                            actionTitle: "Add",
                            cancelTitle: "Cancel",
                            inputPlaceholder: "Ex: test@gmail.com",
                            inputKeyboardType: .emailAddress, actionHandler:
                                { (input: String?) in
                                    self.save("email", input ?? "")
                                })
        }
        
        // Hide back button -> Since logout button will be there
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func unwindToRecorder(_ sender: UIStoryboardSegue) {}
    
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
        if (UserDefaults.standard.string(forKey: "email")! == "") {
            showInputDialog(title: "Enter your email",
                            subtitle: "Your email is needed to label files",
                            actionTitle: "Add",
                            cancelTitle: "Cancel",
                            inputPlaceholder: "Ex: test@gmail.com",
                            inputKeyboardType: .emailAddress, actionHandler:
                                { (input: String?) in
                                    self.save("email", input ?? "")
                                })
        } else { // if email is found -> tracking can be started
            performSegue(withIdentifier: "Started", sender: self)
        }
    }
    
    func save(_ key: String, _ value: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: "\(key)")
    }
}

extension UIViewController {
    func showInputDialog(title: String? = nil,
                         subtitle: String? = nil,
                         actionTitle: String? = "Add",
                         cancelTitle: String? = "Cancel",
                         inputPlaceholder: String? = nil,
                         inputKeyboardType: UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {

        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))

        self.present(alert, animated: true, completion: nil)
    }
}
