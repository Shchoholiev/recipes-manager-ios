//
//  AddRecipeViewController.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/26/22.
//

import UIKit
import Photos

class AddRecipeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    let imagePickerView = UIImagePickerController()
    
    @IBOutlet weak var contentTypeBar: UISegmentedControl!
    
    @IBOutlet weak var contentStackView: UIStackView!
    
    @IBOutlet weak var content: UITextView!
    
    @IBOutlet weak var ingredientsText: UITextView!
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    
    @IBOutlet weak var ingredientsStackView: UIStackView!
    
    @IBOutlet weak var showTextButton: UIButton!
    
    @IBOutlet weak var parseIngredientsButton: UIButton!
    
    @IBOutlet weak var categoriesTableView: UITableView!
    
    @IBOutlet weak var categoriesTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var calories: UITextField!
    
    @IBOutlet weak var servings: UITextField!
    
    @IBOutlet weak var cookingTime: UITextField!
    
    @IBOutlet weak var isPublicSwitch: UISwitch!
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var recipesService = RecipesService()
    
    var helpersService = HelpersService()
    
    var ingredientsService = IngredientsService()
    
    var isUpdate = false
    
    var recipeId = ""
    
    var wasImageUploaded = false
    
    var ingredients = [Ingredient]()
    
    var categories = [Category]()
    
    var scrollViewHeight: CGFloat = 0;
    
    var showText = true
    
    var recipe: Recipe? = nil
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.view.frame.origin.y = 0
        
        thumbnail.layer.borderWidth = 1
        thumbnail.layer.borderColor = CGColor(gray: 0.3, alpha: 1)
        thumbnail.layer.cornerRadius = 10
        thumbnail.clipsToBounds = true
        let thumbnailTapGesture = UITapGestureRecognizer(target: self, action: #selector(openPhotoPicker))
        thumbnail.isUserInteractionEnabled = true
        thumbnail.addGestureRecognizer(thumbnailTapGesture)
        
        imagePickerView.sourceType = .photoLibrary
        imagePickerView.delegate = self
        
        contentStackView.isHidden = true
        
        ingredientsText.layer.borderWidth = 1
        ingredientsText.layer.borderColor = CGColor(gray: 0.3, alpha: 1)
        ingredientsText.layer.cornerRadius = 10
        ingredientsText.clipsToBounds = true
        
        content.layer.borderWidth = 1
        content.layer.borderColor = CGColor(gray: 0.3, alpha: 1)
        content.layer.cornerRadius = 10
        content.clipsToBounds = true
        
        ingredientsTableView.dataSource = self
        ingredientsTableView.register(UINib(nibName: "IngredientCell", bundle: nil), forCellReuseIdentifier: "IngredientCell")
        ingredientsTableView.delegate = self
        
        categoriesTableView.dataSource = self
        categoriesTableView.register(UINib(nibName: "CategoryChooseCell", bundle: nil), forCellReuseIdentifier: "CategoryChooseCell")
        categoriesTableView.register(UINib(nibName: "ButtonCell", bundle: nil), forCellReuseIdentifier: "ButtonCell")
        
        switchIngredientsView(showText)
//        parseIngredientsButton.isEnabled = false
//        showTextButton.isEnabled = false
    }
    
    func render() {
        if isUpdate {
            titleLabel.text = "Update Recipe"
            createButton.setTitle("Update recipe", for: .normal)
        } else {
            titleLabel.text = "Add Recipe"
            createButton.setTitle("Create recipe", for: .normal)
        }
        
        if !recipeId.isEmpty {
            Task {
                recipe = await recipesService.getRecipeAsync(id: recipeId)
                if let safeRecipe = recipe {
                    ingredients = safeRecipe.ingredients ?? []
                    categories = safeRecipe.categories
                    ingredientsTableView.reloadData()
                    categoriesTableView.reloadData()
                    
                    showText = ingredients.isEmpty
                    switchIngredientsView(showText)
                    
                    name.text = safeRecipe.name
                    ingredientsText.text = safeRecipe.ingredientsText
                    content.text = safeRecipe.text
                    if let safeCalories = safeRecipe.calories {
                        calories.text = String(safeCalories)
                    }
                    if let safeServings = safeRecipe.servingsCount {
                        servings.text = String(safeServings)
                    }
                    if let safeCookingTime = safeRecipe.minutesToCook {
                        cookingTime.text = String(safeCookingTime)
                    }
                    isPublicSwitch.isOn = safeRecipe.isPublic ?? false
                    
                    Task {
                        if let image = safeRecipe.thumbnail {
                            if let thumbnailGuid = image.originalPhotoGuid {
                                let imageData = await helpersService.downloadImage(from: "https://l7l2.c16.e2-2.dev/recipes/" + thumbnailGuid + "." + (safeRecipe.thumbnail?.extension)!)
                                if let safeData = imageData {
                                    thumbnail.contentMode = .scaleAspectFill
                                    thumbnail.image = UIImage(data: safeData)
                                } else {
                                    thumbnail.contentMode = .center
                                    thumbnail.image = UIImage(systemName: "photo")
                                }
                            } else {
                               
                            }
                        } else {
                            thumbnail.contentMode = .center
                            thumbnail.image = UIImage(systemName: "photo")
                        }
                    }
                    
//                    if recipe?.ingredientsText == nil {
//                        parseIngredientsButton.isEnabled = false
//                    }
//
//                    if ingredients.isEmpty && !showText {
//                        showTextButton.isEnabled = false
//                    }
                }
            }
        }
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
            ingredientsStackView.isHidden = false
            contentStackView.isHidden = true
            if ingredients.isEmpty || showText {
                ingredientsText.isHidden = false
                ingredientsTableView.isHidden = true
            } else {
                ingredientsText.isHidden = true
                ingredientsTableView.isHidden = false
            }
            
        case 1:
            ingredientsStackView.isHidden = true
            contentStackView.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func showTextClick(_ sender: UIButton) {
        showText = !showText
        switchIngredientsView(showText)
    }
    
    func switchIngredientsView(_ showText: Bool) {
        if showText {
            ingredientsText.isHidden = false
            ingredientsTableView.isHidden = true
            showTextButton.setTitle("Show Table", for: .normal)
            parseIngredientsButton.setTitle("Parse ingredients", for: .normal)
        } else {
            ingredientsText.isHidden = true
            ingredientsTableView.isHidden = false
            showTextButton.setTitle("Show Text", for: .normal)
            parseIngredientsButton.setTitle("Estimate calories", for: .normal)
        }
    }
    
    @objc func openPhotoPicker() {
        present(imagePickerView, animated: true)
    }
    
    @IBAction func parseIngredientsClick(_ sender: UIButton) {
        parseIngredientsButton.isEnabled = false
        showTextButton.isEnabled = false
        createButton.isEnabled = false
        if showText {
            if let text = ingredientsText.text {
                parseIngredients(text)
            }
        } else {
            if !ingredients.isEmpty {
                estimateCalories(ingredients)
            }
        }
    }
    
    func parseIngredients(_ text: String) {
        createButton.setTitle("Parsing ingredients...", for: .normal)
        Task {
            do {
                let ingredients = try await ingredientsService.parseIngredients(text)
                self.ingredients = []
                ingredientsTableView.reloadData()
                showText = false;
                switchIngredientsView(false)
                for await ingredient in ingredients {
                    self.ingredients.append(ingredient)
                    let newIndexPath = IndexPath(row: self.ingredients.count - 1, section: 0)
                    ingredientsTableView.insertRows(at: [newIndexPath], with: .automatic)
                }
                parseIngredientsButton.isEnabled = true
                showTextButton.isEnabled = true
                createButton.isEnabled = true
                createButton.setTitle("Create recipe", for: .normal)
            } catch {
                print(error)
                parseIngredientsButton.isEnabled = true
                showTextButton.isEnabled = true
                createButton.isEnabled = true
                createButton.setTitle("Create recipe", for: .normal)
            }
        }
    }
    
    func estimateCalories(_ ingredientsInput: [Ingredient]) {
        createButton.setTitle("Estimating calories...", for: .normal)
        Task {
            do {
                let ingredients = try await ingredientsService.estimateCalories(ingredientsInput)
                var index = 0;
                for await ingredient in ingredients {
                    self.ingredients[index] = ingredient
                    let indexPath = IndexPath(row: index, section: 0)
                    ingredientsTableView.reloadRows(at: [indexPath], with: .automatic)
                    index += 1
                }
                calories.text = String(ingredientsService.calculateTotalCalories(self.ingredients))
                parseIngredientsButton.isEnabled = true
                showTextButton.isEnabled = true
                createButton.isEnabled = true
                createButton.setTitle("Create recipe", for: .normal)
            } catch {
                print(error)
                parseIngredientsButton.isEnabled = true
                showTextButton.isEnabled = true
                createButton.isEnabled = true
                createButton.setTitle("Create recipe", for: .normal)
            }
        }
    }
    
    func showCategories(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showCategories", sender: nil)
    }
    
    func chooseCategory(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories.remove(at: index)
        } else {
            categories.append(category)
        }
        categoriesTableView.reloadData()
    }
    
    @IBAction func submit(_ sender: UIButton) {
        createButton.isEnabled = false
        
        guard let name = name.text, !name.isEmpty else {
            showAlert(title: "Missing field", message: "Please provide Recipe name.")
            createButton.isEnabled = true
            return
        }
        if categories.isEmpty {
            showAlert(title: "Missing field", message: "Please choose at least one Category.")
            createButton.isEnabled = true
            return
        }
        var calories: Int? = nil
        if let caloriesString = self.calories?.text, !caloriesString.isEmpty {
            if let caloriesInt = Int(caloriesString) {
                calories = caloriesInt
            } else {
                showAlert(title: "Invalid data", message: "Please provide valid number of Calories.")
                createButton.isEnabled = true
                return
            }
        }
        var servingsCount: Int? = nil
        if let servingsString = self.servings?.text, !servingsString.isEmpty {
            if let servingsInt = Int(servingsString) {
                servingsCount = servingsInt
            } else {
                showAlert(title: "Invalid data", message: "Please provide valid number of Servings.")
                createButton.isEnabled = true
                return
            }
        }
        var minutesToCook: Int? = nil
        if let minutesString = self.cookingTime?.text, !minutesString.isEmpty {
            if let minutes = Int(minutesString) {
                minutesToCook = minutes
            } else {
                showAlert(title: "Invalid data", message: "Please provide valid number of calories.")
                createButton.isEnabled = true
                return
            }
        }
        if isPublicSwitch.isOn {
            if (!wasImageUploaded && !isUpdate) || ingredients.isEmpty || content.text == nil || minutesToCook == nil {
                showAlert(title: "Not all Criteria met", message: "To make Recipe public provide: Photo, Ingredients array, Instructions and Cooking Time.")
                createButton.isEnabled = true
                return
            }
        }
        Task {
            let thumbnailData = wasImageUploaded ? thumbnail.image?.jpegData(compressionQuality: 0.8) : nil
            
            let recipe = RecipeCreateDto(name: name, text: content.text, thumbnail: thumbnailData, ingredients: ingredients, ingredientsText: ingredientsText.text, categories: categories, calories: calories, servingsCount: servingsCount, minutesToCook: minutesToCook, isPublic: isPublicSwitch.isOn)
            
            var succeded = false
            if isUpdate {
                let result = await recipesService.updateRecipe(recipeId, recipe)
                if result != nil {
                    succeded = true
                    reset()
                    self.performSegue(withIdentifier: "unwindToRecipe", sender: nil)
                }
            } else {
                let result = await recipesService.createRecipe(recipe)
                if let newRecipe = result {
                    recipeId = newRecipe.id
                    succeded = true
                    reset()
                    self.performSegue(withIdentifier: "showRecipe", sender: nil)
                }
            }
            
            if !succeded {
                showAlert(title: "Error", message: "Error occured while saving recipe. Try again Please.")
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
            let keyboardHeight = keyboardSize.height
            var offset = CGFloat()
            if calories.isFirstResponder {
                let textFieldFrame = calories.convert(calories.bounds, to: self.view)
                offset = textFieldFrame.maxY - (self.view.frame.height - keyboardHeight)
            }
            if servings.isFirstResponder {
                let textFieldFrame = servings.convert(servings.bounds, to: self.view)
                offset = textFieldFrame.maxY - (self.view.frame.height - keyboardHeight)
            }
            if cookingTime.isFirstResponder {
                let textFieldFrame = cookingTime.convert(cookingTime.bounds, to: self.view)
                offset = textFieldFrame.maxY - (self.view.frame.height - keyboardHeight)
            }
            if isUpdate {
                offset += 20
            }
            
            self.view.frame.origin.y = -offset
        }
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showCategories":
            let view = segue.destination as! ChooseCategoryViewController
            view.chooseCategoryCallback = chooseCategory
            view.chosenCategories = categories
        case "showRecipe":
            let view = segue.destination as! RecipeViewController
            view.id = recipeId
        case "unwindToRecipe":
            let view = segue.destination as! RecipeViewController
            view.id = recipeId
            view.viewDidLoad()
        default:
            break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
            if (scrollViewHeight == 0) {
                scrollViewHeight = scrollView.contentSize.height
            }
            categoriesTableHeight.constant = CGFloat(categories.count * 54 + 43)
            scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollViewHeight + CGFloat(categories.count * 54))

            return categories.count + 1;
        }
        return 0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1 {
            // Ingredients table
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath) as! IngredientCell
            
            let entity = ingredients[indexPath.row]
            cell.ingredient = entity
            cell.render()
            
            return cell
        } else {
            // Categories table
            if indexPath.row < categories.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryChooseCell", for: indexPath) as! CategoryChooseCell
                let category = categories[indexPath.row]
                cell.category = category
                cell.delegate = self
                cell.setValues()
                return cell;
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! ButtonCell
                cell.button.setTitle("Choose categories", for: .normal)
                cell.onClick = showCategories
                
                return cell;
            }
        }
    }
}

//MARK: - CategoryChooseCellDelegate
extension AddRecipeViewController: CategoryChooseCellDelegate {
    func categoryDeleteDidTap(_ cell: CategoryChooseCell) {
        if let index = categories.firstIndex(where: { $0.id == cell.category?.id }) {
            categories.remove(at: index)
            categoriesTableView.reloadData()
        }
    }
}

//MARK: - UITableViewDelegate
extension AddRecipeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
            guard let slidingCell = cell as? IngredientCell else { return }
            slidingCell.animate()
        }
    }
}
