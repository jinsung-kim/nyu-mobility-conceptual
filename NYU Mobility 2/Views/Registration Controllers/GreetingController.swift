//
//  GreetingController.swift
//  NYU Mobility 2
//
//  Created by Jin Kim on 8/10/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import Device
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
        view.backgroundColor = Colors.nyuBackground
        layoutSetup()
        exitEdit()
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
        save("email", email.text!)
        save("password", password.text!)
        
        validLogin {
            self.performSegue(withIdentifier: "ToTracking", sender: self)
        }
    }
    
    func validLogin(completionOuter: @escaping () -> Void) {
        completionOuter()
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
