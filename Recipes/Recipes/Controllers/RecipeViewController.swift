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
    
    @IBOutlet weak var ingredients: UILabel!
    
    @IBOutlet weak var recipeText: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var id: String?
    
    var recipe: RecipeOld?
    
    let helpersService = HelpersService()
    
    let recipesService = RecipesService()
    
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        if let safeId = id {
            Task {
                recipe = await recipesService.getRecipeAsync(id: 1)
                if let safeRecipe = recipe {
                    categoryName.text = safeRecipe.category.name
                    recipeName.text = safeRecipe.name
                    ingredients.text = safeRecipe.ingredients
                    recipeText.text = safeRecipe.text
                    let imageData = await helpersService.downloadImage(from: safeRecipe.thumbnail)
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
        let scrollHeight = recipeText.frame.origin.y + recipeText.frame.size.height + 100
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollHeight)
        containerHeight.constant = scrollHeight
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
            if let id = recipe?.id {
                view.recipeId = id
            }
            view.name.text = recipe?.name
            view.thumbnailLink.text = recipe?.thumbnail
            view.setImage()
            view.ingredients.text = recipe?.ingredients
            view.text.text = recipe?.text
            if let categoryId = recipe?.category.id {
                view.selectedCategoryId = categoryId
            }
            view.selectedCategoryText.text = recipe?.category.name
        case "unwindToRecipes":
            let view = segue.destination as! RecipesViewController
            view.setPage(pageNumber: 1)
        default:
            break
        }
    }
    
    @IBAction func deleteRecipe(_ sender: UIButton) {
        Task {
            if let id = recipe?.id {
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
