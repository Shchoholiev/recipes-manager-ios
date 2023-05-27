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
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var contentTypeBar: UISegmentedControl!
    
    @IBOutlet weak var content: UITextView!
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    
    @IBOutlet weak var ingredientsStackView: UIStackView!
    
    @IBOutlet weak var showTextButton: UIButton!
    
    @IBOutlet weak var parseIngredientsButton: UIButton!
    
    @IBOutlet weak var categoriesTableView: UITableView!
    
    @IBOutlet weak var calories: UITextField!
    
    @IBOutlet weak var servings: UITextField!
    
    @IBOutlet weak var cookingTime: UITextField!
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var recipesService = RecipesService()
    
    var helpersService = HelpersService()
    
    var isUpdate = false
    
    var recipeId = ""
    
    var wasImageUploaded = false
    
    var ingredients = [Ingredient]()
    
    var ingredientsText = ""
    
    var instructions = ""
    
    var categories = [Category]()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        if isUpdate {
            createButton.setTitle("Update recipe", for: .normal)
        } else {
            createButton.setTitle("Create recipe", for: .normal)
        }
        
        thumbnail.layer.borderWidth = 1
        thumbnail.layer.borderColor = CGColor(gray: 0.3, alpha: 1)
        thumbnail.layer.cornerRadius = 10
        thumbnail.clipsToBounds = true
        
        if ingredients.isEmpty {
            ingredientsStackView.isHidden = true
        } else {
            content.isHidden = true
        }
        
        if ingredientsText.isEmpty {
            showTextButton.isEnabled = false
            parseIngredientsButton.isEnabled = false
        }
        
        content.layer.borderWidth = 1
        content.layer.borderColor = CGColor(gray: 0.3, alpha: 1)
        content.layer.cornerRadius = 10
        content.clipsToBounds = true
        
        ingredientsTableView.dataSource = self
        ingredientsTableView.register(UINib(nibName: "IngredientCell", bundle: nil), forCellReuseIdentifier: "IngredientCell")
        
        categoriesTableView.dataSource = self
        categoriesTableView.register(UINib(nibName: "CategoryChooseCell", bundle: nil), forCellReuseIdentifier: "CategoryChooseCell")
        categoriesTableView.register(UINib(nibName: "ButtonCell", bundle: nil), forCellReuseIdentifier: "ButtonCell")
        
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
    
    
    @IBAction func contentBarChanged(_ sender: Any) {
        switch contentTypeBar.selectedSegmentIndex {
            case 0:
                if ingredients.isEmpty {
                    content.text = ingredientsText
                    ingredientsStackView.isHidden = true
                    content.isHidden = false
                } else {
                    ingredientsStackView.isHidden = false
                    content.isHidden = true
                }
                break
            case 1:
                ingredientsStackView.isHidden = true
                content.isHidden = false
                content.text = instructions
                break
            default:
                break
        }
    }
    
    @IBAction func openPhotoPicker(_ sender: UIButton) {
        let imagePickerView = UIImagePickerController()
        imagePickerView.sourceType = .photoLibrary
        imagePickerView.delegate = self
        present(imagePickerView, animated: true)
    }
    
    func showCategories(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showCategories", sender: nil)
    }
    
    func chooseCategory(_ category: Category) {
        categories.append(category)
    }
    
    @IBAction func submit(_ sender: UIButton) {
        sender.isEnabled = false
        
        guard let name = name.text else {
            showAlert(title: "Missing field", message: "Please add name.")
            return
        }
//        guard let ingredients = ingredients.text else { return }
//        guard let text = text.text else { return }
//        if selectedCategoryId < 1 { return }
        
        Task {
//            var thumbnail = ""
//            if let link = thumbnailLink.text, !link.isEmpty {
//                thumbnail = link
//            } else if wasImageUploaded {
//                let thumbnailData = self.thumbnail.image?.jpegData(compressionQuality: 0.2)
//                let uploadedLink = await helpersService.uploadImage(imageData: thumbnailData, blobContainer: "recipes-photos")
//                if let safeThumbnail = uploadedLink {
//                    thumbnail = safeThumbnail
//                }
//            }
             
//            let recipe = RecipeOld(id: recipeId, name: name, ingredients: ingredients, text: text, thumbnail: thumbnail, category: CategoryOld(id: selectedCategoryId, name: ""))
//
            var succeded = false
//            if isUpdate {
//                succeded = await recipesService.updateRecipe(recipe)
//                if succeded {
//                    self.performSegue(withIdentifier: "unwindToRecipe", sender: nil)
//                }
//            } else {
//                succeded = await recipesService.createRecipe(recipe)
//            }
            
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
            if calories.isFirstResponder {
                self.view.frame.origin.y = -keyboardSize.height
            }
            if servings.isFirstResponder {
                self.view.frame.origin.y = -keyboardSize.height
            }
            if cookingTime.isFirstResponder {
                self.view.frame.origin.y = -keyboardSize.height
            }
        }
    }
    
//    func setImage() {
//        if let imageLink = thumbnailLink.text {
//            Task {
//                let image = await helpersService.downloadImage(from: imageLink)
//                if let imageData = image {
//                    thumbnail.image = UIImage(data: imageData)
//                    thumbnail.contentMode = .scaleAspectFill
//                }
//            }
//        }
//    }
    
    func reset() {
        name.text = ""
//        thumbnailLink.text = ""
//        ingredients.text = ""
//        text.text = ""
//        selectedCategoryId = 0
//        selectedCategoryText.text = "None"
        thumbnail.contentMode = .center
        thumbnail.image = UIImage(systemName: "photo")
    }
    
    @IBAction func unwindToAddRecipe( _ seg: UIStoryboardSegue) {}
    
//    @IBAction func createCategory(_ sender: UIButton) {
//        sender.isEnabled = false
//
//        if let categoryName = newCategoryName.text, !categoryName.isEmpty {
//            Task {
//                let newId = await categoriesService.createCategory(CategoryOld(id: 0, name: categoryName))
//                if newId > 0 {
//                    selectedCategoryText.text = newCategoryName.text
//                    selectedCategoryId = newId
//                    newCategoryName.text = ""
//                } else {
//                    showAlert(title: "Error", message: "Error occured while saving category.")
//                }
//
//                sender.isEnabled = true
//            }
//        } else {
//            showAlert(title: "Error", message: "Enter category name.")
//        }
//    }
    
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
//            view.chooseCategoryCallback = chooseCategory
        case "unwindToRecipe":
            let view = segue.destination as! RecipeViewController
            Task {
                if let recipe = await recipesService.getRecipeAsync(id: recipeId) {
//                    view.recipeOld = recipe
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
            wasImageUploaded = true
        }
    }
}

//MARK: - UITextFieldDelegate
extension AddRecipeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        setImage()
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

//MARK: - UITableViewDataSource
extension AddRecipeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            // Ingredients table
            return ingredients.count;
        } else if tableView.tag == 2 {
            // Categories table
            return categories.count + 1;
        }
        return 0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1 {
            // Ingredients table
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath) as! IngredientCell
            
            let entity = ingredients[indexPath.row]
            cell.ingredientName?.text = entity.name
            
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = entity.amount.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1
            let stringAmount = numberFormatter.string(from: NSNumber(value: entity.amount)) ?? ""
            cell.ingredientAmount?.text = stringAmount + " " + (entity.units ?? "")
            
            return cell
        } else {
            // Categories table
            if indexPath.row < categories.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryChooseCell", for: indexPath) as! CategoryChooseCell
                
                return cell;
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! ButtonCell
                cell.button.setTitle("Choose category", for: .normal)
                cell.onClick = showCategories
                
                return cell;
            }
        }
    }
}
