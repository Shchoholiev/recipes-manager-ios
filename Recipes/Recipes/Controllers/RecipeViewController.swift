//
//  RecipeController.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/12/22.
//

import UIKit

class RecipeViewController: UIViewController {
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var categoryName: UILabel!
    
    @IBOutlet weak var recipeName: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var id: String?
    
    var recipeOld: RecipeOld?
    
    var recipe: Recipe?
    
    let helpersService = HelpersService()
    
    let recipesService = RecipesService()
    
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        if let safeId = id {
            Task {
                recipe = await recipesService.getRecipeAsync(id: self.id!)
                if let safeRecipe = recipe {
                    categoryName.text = safeRecipe.categories.first?.name
                    recipeName.text = safeRecipe.name
//                    ingredients.text = safeRecipe.ingredients
//                    recipeText.text = safeRecipe.text
                    let imageData = await helpersService.downloadImage(from: "https://l7l2.c16.e2-2.dev/recipes/" + recipe.thumbnail?.originalPhotoGuid! + "." + recipe.thumbnail?.extension!)
                    if let safeData = imageData {
                        thumbnail.image = UIImage(data: safeData)
                        thumbnail.contentMode = .scaleAspectFill
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLayoutSubviews() {
//     let scrollHeight = recipeText.frame.origin.y + recipeText.frame.size.height + 100
//        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollHeight)
//        containerHeight.constant = scrollHeight
    }
    
    
    @IBAction func editRecipe(_ sender: UIButton) {
        Task {
            self.performSegue(withIdentifier: "showAddRecipe", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showAddRecipe":
            let view = segue.destination as! AddRecipeViewController
            view.isUpdate = true
            view.viewDidLoad()
            if let id = recipeOld?.id {
                view.recipeId = id
            }
            view.name.text = recipeOld?.name
            view.thumbnailLink.text = recipeOld?.thumbnail
            view.setImage()
            view.ingredients.text = recipeOld?.ingredients
            view.text.text = recipeOld?.text
            if let categoryId = recipeOld?.category.id {
                view.selectedCategoryId = categoryId
            }
            view.selectedCategoryText.text = recipeOld?.category.name
        case "unwindToRecipes":
            let view = segue.destination as! RecipesViewController
            view.setPage(pageNumber: 1)
        default:
            break
        }
    }
    
    @IBAction func deleteRecipe(_ sender: UIButton) {
        Task {
            if let id = recipeOld?.id {
                let result = await recipesService.deleteAsync(id: id)
                if result {
                    self.performSegue(withIdentifier: "unwindToRecipes", sender: self)
                }
            }
        }
    }
    
    @IBAction func unwindToRecipe( _ seg: UIStoryboardSegue) {
    }
}
