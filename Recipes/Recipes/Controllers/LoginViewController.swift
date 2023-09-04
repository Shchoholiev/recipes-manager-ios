//
//  LoginViewController.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/28/23.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var phone: UITextField!
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    var callback: (() -> ())?
    
    let authService = AuthSerice()
    
    override func viewDidLoad() {
        loginButton.isEnabled = false
        email.delegate = self
        phone.delegate = self
        password.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false
        
        if (email.text == nil || email.text!.isEmpty) && (phone.text == nil || phone.text!.isEmpty) {
            showAlert(title: "Missing data", message: "Please enter phone or email")
            return
        }
        guard let password = password.text else {
            showAlert(title: "Missing password", message: "Please enter password")
            return
        }
        
        Task {
            let user = LoginModel(email: email.text, phone: phone.text, password: password)
            let isSuccessful = await authService.login(user)
            if isSuccessful {
                dismiss()
                sender.isEnabled = true
            } else {
                showAlert(title: "Unsuccessful login", message: "Please review the data you provided")
            }
        }
    }
    
    @IBAction func loginAsGuestTapped(_ sender: UIButton) {
        authService.loginAsGuest()
        dismiss()
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        guard let regex = try? NSRegularExpression(pattern: emailRegex) else {
            return false
        }
        let matches = regex.matches(in: email, range: NSRange(location: 0, length: email.count))

        return matches.count > 0
    }
    
    func isValidPhoneNumber(phoneNumber: String) -> Bool {
        let phoneRegex = "^[0-9]+$"
        guard let regex = try? NSRegularExpression(pattern: phoneRegex) else {
            return false
        }
        let matches = regex.matches(in: phoneNumber, range: NSRange(location: 0, length: phoneNumber.count))
        
        return matches.count > 0 && phoneNumber.count >= 6 && phoneNumber.count <= 15
    }
    
    func canLogin() -> Bool {
        var isValid = true
        
        if (email.text == nil || email.text!.isEmpty) && (phone.text == nil || phone.text!.isEmpty) {
            isValid = false
        }
        
        if let email = email.text, !email.isEmpty {
            if !isValidEmail(email: email) {
                isValid = false
            }
        }
        
        if let phone = phone.text, !phone.isEmpty {
            if !isValidPhoneNumber(phoneNumber: phone) {
                isValid = false
            }
        }
        
        if password.text == nil || password.text!.isEmpty || password.text!.count < 7 {
            isValid = false
        }
        
        return isValid
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
        
        Task {
            try await Task.sleep(nanoseconds: UInt64(10_000_000))  // Sleep for 0.01 second
            if let callbackFunction = callback {
                callbackFunction()
            }
            reset()
        }
    }
    
    func reset() {
        email.text = nil
        phone.text = nil
        password.text = nil
        emailLabel.text = "Email"
        phoneLabel.text = "Phone"
        passwordLabel.text = "Password"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillHide() {
        self.view.frame.origin.y = 0
    }

    @objc func keyboardWillChange(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            var offset = CGFloat()
            if phone.isFirstResponder {
                let textFieldFrame = phone.convert(phone.bounds, to: self.view)
                offset = textFieldFrame.maxY - (self.view.frame.height - keyboardHeight)
            }
            if password.isFirstResponder {
                let textFieldFrame = password.convert(password.bounds, to: self.view)
                offset = textFieldFrame.maxY - (self.view.frame.height - keyboardHeight)
            }
            
            self.view.frame.origin.y = -offset
        }
    }
}

//MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case email:
            if let email = email.text, !email.isEmpty {
                if !isValidEmail(email: email) {
                    emailLabel.text = "Invalid Email"
                } else {
                    emailLabel.text = "Email"
                }
            } else {
                emailLabel.text = "Email"
            }
        case phone:
            if let phone = phone.text, !phone.isEmpty {
                if !isValidPhoneNumber(phoneNumber: phone) {
                    phoneLabel.text = "Invalid Phone"
                } else {
                    phoneLabel.text = "Phone"
                }
            } else {
                phoneLabel.text = "Phone"
            }
        case password:
            if password.text == nil || password.text!.isEmpty || password.text!.count < 7 {
                passwordLabel.text = "Enter at least 7 characters"
            } else {
                passwordLabel.text = "Password"
            }
        default:
            break
        }
        
        loginButton.isEnabled = canLogin()
    }
}
