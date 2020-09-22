//
//  AddUserController.swift
//  NYU Mobility 2
//
//  Created by Jin Kim on 8/10/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
//import Device


class AddUserController: UIViewController {
    
//    private let spinner = JGProgressHUD(style: .dark)
//
//    @IBOutlet weak var username: BubbleTextField!
//    @IBOutlet weak var name: BubbleTextField!
//    @IBOutlet weak var password: BubbleTextField!
//    @IBOutlet weak var passwordConfirm: BubbleTextField!
//
//    @IBOutlet weak var registerButton: BubbleButton!
//
//    var last: UITextField?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = Colors.nyuBackground
//        layoutSetup()
//        exitEdit()
//    }
//
//    func layoutSetup() {
//        // 4.0 inch screen iPhone SE (only device that needs smaller buttons)
//        if (Device.size() == Size.screen4Inch) {
//            username.widthAnchor.constraint(equalToConstant: 250).isActive = true
//            name.widthAnchor.constraint(equalToConstant: 250).isActive = true
//            password.widthAnchor.constraint(equalToConstant: 250).isActive = true
//            passwordConfirm.widthAnchor.constraint(equalToConstant: 250).isActive = true
//        } else {
//            // UI design for labels
//            username.widthAnchor.constraint(equalToConstant: 350).isActive = true
//            name.widthAnchor.constraint(equalToConstant: 350).isActive = true
//            password.widthAnchor.constraint(equalToConstant: 350).isActive = true
//            passwordConfirm.widthAnchor.constraint(equalToConstant: 350).isActive = true
//        }
//
//        registerButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
//        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//
//        // Connect all UITextFields to go to the next
//        UITextField.connectFields(fields: [username, name, password, passwordConfirm])
//
//        // Keyboard settings
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
//                                               name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
//                                               name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if (last != username && last != name) {
//            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//                if view.frame.origin.y == 0 {
//                    view.frame.origin.y -= keyboardSize.height
//                }
//            }
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if view.frame.origin.y != 0 {
//            view.frame.origin.y = 0
//        }
//    }
//
//    @IBAction func keyboardStays(_ sender: UITextField) {
//        last = sender
//    }
//
//    func exitEdit() {
//        let tapGestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
//        self.view.addGestureRecognizer(tapGestureRecognizer)
//    }
//
//    @IBAction func registered(_ sender: Any) {
//        // At least one text field is empty
//        // Uncomment all guards when launching
//        if (username.text!.count == 0 || name.text!.count == 0 ||
//            password.text!.count == 0 || passwordConfirm.text!.count == 0) {
//            alertUserRegistrationError()
//            return
//        }
//
//        // The password is not long enough
//        if (password.text!.count < 6) {
//            alertUserRegistrationError(message: "Password must be at least 6 characters long")
//            return
//        }
//
//        if (password.text! != passwordConfirm.text!) {
//            alertUserRegistrationError(message: "Passwords must match")
//            return
//        }
//
//        spinner.show(in: view)
//
//        // Firebase register attempt
//        DatabaseManager.shared.userExists(with: username.text!, completion: { [weak self] exists in
//            guard let strongSelf = self else {
//                return
//            }
//
//            DispatchQueue.main.async {
//                strongSelf.spinner.dismiss()
//            }
//
//            guard !exists else {
//                strongSelf.alertUserRegistrationError(message: "It seems that a user for that email already exists")
//                return
//            }
//
//            // If the user does not exist -> Add
//            FirebaseAuth.Auth.auth().createUser(withEmail: self!.username.text!, password: self!.password.text!, completion: { authResult, error in
//                guard authResult != nil, error == nil else {
//                    print("Error adding user")
//                    return
//                }
//
//                // Saves all of the user defaults
//                self!.save("username", self!.username.text!) // email treated as username
//                self!.save("password", self!.password.text!)
//                self!.save("name", self!.name.text!)
//
//                let user = User(fullName: self!.name.text!,
//                                username: self!.username.text!,
//                                password: self!.password.text!)
//
//                DatabaseManager.shared.insertUser(with: user, completion: { success in
//                    if success {
//                        // if successful -> redirect
//                        self!.performSegue(withIdentifier: "ToTracking2", sender: self)
//                    }
//                })
//            })
//        })
//    }
//
//    func save(_ key: String, _ value: String) {
//        let defaults = UserDefaults.standard
//        defaults.set(value, forKey: "\(key)")
//    }
//
//    // Error Messages
//    func alertUserRegistrationError(message: String = "Please enter all information to create a new account.") {
//        let alert = UIAlertController(title: "Woops",
//                                      message: message,
//                                      preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title:"Dismiss",
//                                      style: .cancel, handler: nil))
//        present(alert, animated: true)
//    }
}
