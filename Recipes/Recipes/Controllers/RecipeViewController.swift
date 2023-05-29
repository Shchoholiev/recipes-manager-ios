//
//  RecipeController.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/12/22.
//

import UIKit

class RecipeViewController: UIViewController {
    
    @IBOutlet weak var thumbnailLoadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var categoryName: UILabel!
    
    @IBOutlet weak var recipeName: UILabel!
    
    @IBOutlet weak var contentTypeBar: UISegmentedControl!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var savedButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var menuButton: UIButton!
    
    var id: String?
    
    var ingredients = [Ingredient]()
    
    var recipeOld: RecipeOld?
    
    var recipe: Recipe?
    
    let helpersService = HelpersService()
    
    let recipesService = RecipesService()
    
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuButton.isHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "IngredientCell", bundle: nil), forCellReuseIdentifier: "IngredientCell")
        
        if let safeId = id {
            Task {
                recipe = await recipesService.getRecipeAsync(id: safeId)
                if let safeRecipe = recipe {
                    Task {
                        if let image = safeRecipe.thumbnail {
                            if let thumbnailGuid = image.originalPhotoGuid {
                                thumbnail.image = UIImage(systemName: "bookmark.slash.fill")
                                let imageData = await helpersService.downloadImage(from: "https://l7l2.c16.e2-2.dev/recipes/" + thumbnailGuid + "." + (safeRecipe.thumbnail?.extension)!)
                                if let safeData = imageData {
                                    thumbnailLoadingIndicator.stopAnimating()
                                    thumbnail.contentMode = .scaleAspectFill
                                    thumbnail.image = UIImage(data: safeData)
                                } else {
                                    thumbnail.contentMode = .center
                                    thumbnail.image = UIImage(systemName: "photo")
                                }
                            } else {
                               
                            }
                        } else {
                            thumbnailLoadingIndicator.stopAnimating()
                            thumbnail.contentMode = .center
                            thumbnail.image = UIImage(systemName: "photo")
                        }
                    }
                    if let safeIngredients = safeRecipe.ingredients, !safeIngredients.isEmpty {
                        ingredients = safeIngredients
                        tableView.reloadData()
                    } else {
                        contentLabel.text = safeRecipe.ingredientsText
                        tableView.isHidden = true
                        scrollView.isHidden = false
                    }
                    
                    categoryName.text = safeRecipe.categories.first?.name
                    recipeName.text = safeRecipe.name
                    infoLabel.text = String(safeRecipe.calories ?? 0) + " ccal | " + String(safeRecipe.minutesToCook ?? 0) + " min | "
                    + String(safeRecipe.servingsCount ?? 0) + " Servings"
                    contentLabel.text = safeRecipe.ingredientsText
                    if safeRecipe.isSaved == true{
                        savedButton.setImage(UIImage(systemName: "bookmark.slash.fill"), for:.normal)
                    }else{
                        savedButton.setImage(UIImage(systemName: "bookmark.fill"), for:.normal)
                    }
                    
                    if recipe?.createdById != nil && !recipe!.createdById.isEmpty && recipe!.createdById == GlobalUser.shared.id {
                        menuButton.isHidden = false
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLayoutSubviews() {
        let scrollHeight = contentLabel.frame.origin.y + contentLabel.frame.size.height - 300
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollHeight)
        containerHeight.constant = scrollHeight
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showAddRecipe":
            let view = segue.destination as! AddRecipeViewController
            view.isUpdate = true
            view.viewDidLoad()
            if let id = recipe?.id {
                view.recipeId = id
            }
            view.name.text = recipeOld?.name
//            view.thumbnailLink.text = recipeOld?.thumbnail
//            view.setImage()
//            view.ingredients.text = recipeOld?.ingredients
//            view.text.text = recipeOld?.text
//            if let categoryId = recipeOld?.category.id {
//                view.selectedCategoryId = categoryId
//            }
//            view.selectedCategoryText.text = recipeOld?.category.name
        case "unwindToRecipes":
            let view = segue.destination as! RecipesViewController
            view.setPage(pageNumber: 1)
        default:
            break
        }
    }
    
    @IBAction func contentBarChanged(_ sender: Any) {
        switch contentTypeBar.selectedSegmentIndex {
            case 0:
                if ingredients.isEmpty {
                    contentLabel.text = recipe?.ingredientsText
                    tableView.isHidden = true
                    scrollView.isHidden = false
                } else {
                    tableView.isHidden = false
                    scrollView.isHidden = true
                }
                break
            case 1:
                tableView.isHidden = true
                scrollView.isHidden = false
                contentLabel.text = recipe?.text
                break
            default:
                break
        }
    }
    
    @IBAction func saveButtonPushed(_ sender: UIButton) {
        Task{
            if let id = recipe?.id {
                if !(recipe?.isSaved!)!{
                    sender.isEnabled = false
                    let result = await recipesService.saveRecipe(id: id)
                    if result {
                        recipe?.isSaved = true
                        sender.setImage(UIImage(systemName: "bookmark.slash.fill"), for:.normal)
                    }
                    sender.isEnabled = true
                }else{
                    sender.isEnabled = false
                    let result = await recipesService.deleteSaved(id: id)
                    if result {
                        recipe?.isSaved = false
                        sender.setImage(UIImage(systemName: "bookmark.fill"), for:.normal)
                    }
                    sender.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        showMenuOptions()
    }
    
    func showMenuOptions() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let editAction = UIAlertAction(title: "Edit Recipe", style: .default) { _ in
            print("Option 1 selected")
        }
        alertController.addAction(editAction)

        let deleteAction = UIAlertAction(title: "Delete Recipe", style: .destructive) { _ in
            print("Option 2 selected")
            let confirmationAlert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this recipe?", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
                print("OK selected")
            }
            let cancelAction = UIAlertAction(title: "No", style: .cancel) { _ in
                print("Cancel selected")
            }
            
            confirmationAlert.addAction(okAction)
            confirmationAlert.addAction(cancelAction)
            self.present(confirmationAlert, animated: true, completion: nil)
        }
        alertController.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource
extension RecipeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath) as! IngredientCell
        
        let entity = ingredients[indexPath.row]
        cell.ingredient = entity
        cell.render()
        
        return cell
    }
}
