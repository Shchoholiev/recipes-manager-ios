//
//  ProfileViewController.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/28/23.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        nameTextField.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nameTextField.text = GlobalUser.shared.name
    }
}
