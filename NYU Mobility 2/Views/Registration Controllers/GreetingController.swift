//
//  GreetingController.swift
//  NYU Mobility 2
//
//  Created by Jin Kim on 8/10/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import Device
import FirebaseAuth
import FirebaseDatabase
import JGProgressHUD

class GreetingController: UIViewController { // AKA login controller
    
    private let spinner = JGProgressHUD(style: .dark) // spinner for waiting for the login
    
    // Text fields
    @IBOutlet weak var email: BubbleTextField!
    @IBOutlet weak var password: BubbleTextField!
    
    // Interactive buttons
    @IBOutlet weak var loginButton: BubbleButton!
    @IBOutlet weak var registerButton: BubbleButton!
    
    var last: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false // We want to see the bar at all times
        
        // Hide back button -> Since logout button will handle that case
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        
        view.backgroundColor = Colors.nyuBackground
        layoutSetup()
        exitEdit()
        bypassLogin()
    }
    
    /// Use this if the user has already signed in -> go straight to the tracking controller
    func bypassLogin() {
        if (UserDefaults.standard.string(forKey: "name") != "") {
            performSegue(withIdentifier: "ToTracking", sender: self)
        }
    }
    
    func layoutSetup() {
        if (Device.size() == Size.screen4Inch) {
            email.widthAnchor.constraint(equalToConstant: 250).isActive = true
            password.widthAnchor.constraint(equalToConstant: 250).isActive = true
        } else {
            email.widthAnchor.constraint(equalToConstant: 350).isActive = true
            password.widthAnchor.constraint(equalToConstant: 350).isActive = true
        }
        
        loginButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        registerButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Connect all UITextFields to go to the next
        UITextField.connectFields(fields: [email, password])
        
        // Keyboard settings
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Called when we leave this view controller, whether that is going back or finished
    override func viewDidDisappear(_ animated: Bool) {
        // Cleaning up to avoid any unnecessary notification messages
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if (last != email) {
            if (Device.size() == Size.screen4Inch) {
                if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    if view.frame.origin.y == 0 {
                        view.frame.origin.y -= keyboardSize.height
                    }
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    @IBAction func keyboardStays(_ sender: BubbleTextField) {
        last = sender
    }
    
    
    
    @IBAction func loginSubmitted(_ sender: Any) {
        save("username", email.text!)
        save("password", password.text!)
        save("name", "") // Reset the value of the name
        
        validLogin { res in
            if (res) { // Login successful
                self.performSegue(withIdentifier: "ToTracking", sender: self)
            } else {
                self.alertUserLoginError()
            }
        }
    }
    
    func validLogin(completion: @escaping (Bool) -> Void) {
        let email = UserDefaults.standard.string(forKey: "username")
        let password = UserDefaults.standard.string(forKey: "password")
        
        spinner.show(in: view)

        // Validate Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email!, password: password!, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let _ = authResult, error == nil else {
                print("Failed to log in user with email: \(email!)")
                completion(false)
                return
            }
            
            let safeEmail = DatabaseManager.safeEmail(email!)
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                switch (result) {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                        let name = userData["name"] as? String else {
                            return
                    }
                    // Stores mode for the user
                    UserDefaults.standard.set(name, forKey: "name")
                    completion(true)
                case .failure(let error):
                    print("Failed to read data with error: \(error)")
                    // Values will not pass
                    UserDefaults.standard.set("", forKey: "name")
                }
            })
        })
    }
    
    func exitEdit() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func save(_ key: String, _ value: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: "\(key)")
    }
    
    // Error message
    func alertUserLoginError(message: String = "Login unsuccessful") {
        let alert = UIAlertController(title: "Woops",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

// Used to go from one UITextField to the next
extension UITextField {
    class func connectFields(fields: [UITextField]) -> Void {

        guard let last = fields.last else {
            return
        }
        for i in 0 ..< fields.count - 1 {
            fields[i].returnKeyType = .next
            fields[i].addTarget(fields[i + 1], action: #selector(self.becomeFirstResponder), for: .editingDidEndOnExit)
        }
        last.returnKeyType = .done
        last.addTarget(last, action: #selector(UIResponder.resignFirstResponder), for: .editingDidEndOnExit)
    }
}
