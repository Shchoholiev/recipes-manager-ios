//
//  AddRecipeViewController.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/26/22.
//

import UIKit
import Photos

class AddRecipeViewController: UIViewController {
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var thumbnailLink: UITextField!
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var ingredients: UITextView!
    
    @IBOutlet weak var text: UITextView!
    
    @IBOutlet weak var selectedCategoryBackground: UIView!
    
    @IBOutlet weak var selectedCategoryText: UILabel!
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var newCategoryName: UITextField!
    
    var selectedCategoryId = 0
    
    var wasImageUpload = false
    
    var isUpdate = false
    
    var recipeId = 0
    
    var recipesService = RecipesService()
    
    var categoriesService = CategoriesService()
    
    var helpersService = HelpersService()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        thumbnail.layer.borderWidth = 1
        thumbnail.layer.borderColor = CGColor(gray: 0.3, alpha: 1)
        thumbnail.layer.cornerRadius = 10
        thumbnail.clipsToBounds = true
        
        ingredients.layer.borderWidth = 1
        ingredients.layer.borderColor = CGColor(gray: 0.3, alpha: 1)
        ingredients.layer.cornerRadius = 10
        ingredients.clipsToBounds = true
        
        text.layer.borderWidth = 1
        text.layer.borderColor = CGColor(gray: 0.3, alpha: 1)
        text.layer.cornerRadius = 10
        text.clipsToBounds = true
        
        selectedCategoryBackground.layer.cornerRadius = 10
        
        if isUpdate {
            createButton.setTitle("Update recipe", for: .normal)
        } else {
            createButton.setTitle("Create recipe", for: .normal)
        }
        
        thumbnailLink.delegate = self
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    
//    override func viewDidLayoutSubviews() {
//        let scrollHeight = createButton.frame.origin.y + createButton.frame.size.height + 50
//        print(createButton.frame.origin.y)
//        print(text.frame.origin.y)
//        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollHeight)
//        
//        contentHeight.constant = scrollHeight
//    }
    
    @IBAction func openPhotoPicker(_ sender: UIButton) {
        let imagePickerView = UIImagePickerController()
        imagePickerView.sourceType = .photoLibrary
        imagePickerView.delegate = self
        present(imagePickerView, animated: true)
    }
    
    @IBAction func showCategories(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showCategories", sender: nil)
    }
    
    func chooseCategory(_ category: Category) {
        selectedCategoryText.text = category.name
        selectedCategoryId = category.id
        
        newCategoryName.text = ""
    }
    
    @IBAction func submit(_ sender: UIButton) {
        sender.isEnabled = false
        
        guard let name = name.text else { return }
        guard let ingredients = ingredients.text else { return }
        guard let text = text.text else { return }
        if selectedCategoryId < 1 { return }
        
        Task {
            var thumbnail = ""
            if let link = thumbnailLink.text, !link.isEmpty {
                thumbnail = link
            } else if wasImageUpload {
                let thumbnailData = self.thumbnail.image?.jpegData(compressionQuality: 0.2)
                let uploadedLink = await helpersService.uploadImage(imageData: thumbnailData, blobContainer: "recipes-photos")
                if let safeThumbnail = uploadedLink {
                    thumbnail = safeThumbnail
                }
            }
             
            let recipe = RecipeOld(id: recipeId, name: name, ingredients: ingredients, text: text, thumbnail: thumbnail, category: Category(id: selectedCategoryId, name: ""))
            
            var succeded = false
            if isUpdate {
                succeded = await recipesService.updateRecipe(recipe)
                if succeded {
                    self.performSegue(withIdentifier: "unwindToRecipe", sender: nil)
                }
            } else {
                succeded = await recipesService.createRecipe(recipe)
            }
            
            if succeded {
                showAlert(title: "Success", message: "New recipe added!")
                reset()
            } else {
                showAlert(title: "Error", message: "Error occured while saving recipe.")
            }
            
            sender.isEnabled = true
        }
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
            if newCategoryName.isFirstResponder {
                self.view.frame.origin.y = -keyboardSize.height
            }
        }
    }
    
    func setImage() {
        if let imageLink = thumbnailLink.text {
            Task {
                let image = await helpersService.downloadImage(from: imageLink)
                if let imageData = image {
                    thumbnail.image = UIImage(data: imageData)
                    thumbnail.contentMode = .scaleAspectFill
                }
            }
        }
    }
    
    func reset() {
        name.text = ""
        thumbnailLink.text = ""
        ingredients.text = ""
        text.text = ""
        selectedCategoryId = 0
        selectedCategoryText.text = "None"
        thumbnail.contentMode = .center
        thumbnail.image = UIImage(systemName: "photo")
    }
    
    @IBAction func unwindToAddRecipe( _ seg: UIStoryboardSegue) {}
    
    @IBAction func createCategory(_ sender: UIButton) {
        sender.isEnabled = false
        
        if let categoryName = newCategoryName.text, !categoryName.isEmpty {
            Task {
                let newId = await categoriesService.createCategory(Category(id: 0, name: categoryName))
                if newId > 0 {
                    selectedCategoryText.text = newCategoryName.text
                    selectedCategoryId = newId
                    newCategoryName.text = ""
                } else {
                    showAlert(title: "Error", message: "Error occured while saving category.")
                }
                
                sender.isEnabled = true
            }
        } else {
            showAlert(title: "Error", message: "Enter category name.")
        }
    }
    
    func showAlert(title: String, message: String) {
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        dialogMessage.addAction(ok)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showCategories":
            let view = segue.destination as! ChooseCategoryViewController
            view.chooseCategoryCallback = chooseCategory
        case "unwindToRecipe":
            let view = segue.destination as! RecipeViewController
            Task {
                if let recipe = await recipesService.getRecipeAsync(id: recipeId) {
                    view.recipe = recipe
                    view.viewDidLoad()
                }
            }
        default:
            break
        }
    }
    
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            if view.frame.origin.y == 0 {
//                self.view.frame.origin.y -= keyboardSize.height
//            }
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if view.frame.origin.y != 0 {
//            self.view.frame.origin.y = 0
//        }
//    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension AddRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let image = info[.originalImage] as? UIImage {
            thumbnail.contentMode = .scaleAspectFill
            thumbnail.image = image
            thumbnailLink.text = ""
            wasImageUpload = true
        }
    }
}

//MARK: - UITextFieldDelegate
extension AddRecipeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        setImage()
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
}
