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
    
    @IBOutlet weak var contentTypeBar: UISegmentedControl!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var savedButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var id: String?
    
    var ingredients = [Ingredient]()
    
    var recipeOld: RecipeOld?
    
    var recipe: Recipe?
    
    let helpersService = HelpersService()
    
    let recipesService = RecipesService()
    
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "IngredientCell", bundle: nil), forCellReuseIdentifier: "IngredientCell")
        
//        tableView.isHidden = false
//        scrollView.isHidden = true
        
        if let safeId = id {
            Task {
                recipe = await recipesService.getRecipeAsync(id: safeId)
                if let safeRecipe = recipe {
                    if let safeIngredients = safeRecipe.ingredients{
                        ingredients = safeIngredients
                        tableView.reloadData()
                    }else{
                        
                    }
                    categoryName.text = safeRecipe.categories.first?.name
                    recipeName.text = safeRecipe.name
                    contentLabel.text = safeRecipe.ingredientsText
//                    if(safeRecipe.ingredients?.isEmpty == false){
//                        tableView.isHidden = false
//                        scrollView.isHidden = true
//                    }
                    if safeRecipe.isSaved! == true{
                        savedButton.alpha = 0.6
                    }
                    
                    let imageData = await helpersService.downloadImage(from: "https://l7l2.c16.e2-2.dev/recipes/" + (safeRecipe.thumbnail?.originalPhotoGuid)! + "." + (safeRecipe.thumbnail?.extension)!)
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
        let scrollHeight = contentLabel.frame.origin.y + contentLabel.frame.size.height + 100
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollHeight)
        containerHeight.constant = scrollHeight
    }
    
    
    //    @IBAction func editRecipe(_ sender: UIButton) {
    //        Task {
    //            self.performSegue(withIdentifier: "showAddRecipe", sender: self)
    //        }
    //    }
    
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
    @IBAction func contentBarChanged(_ sender: Any) {
        switch contentTypeBar.selectedSegmentIndex{
        case 0:
            contentLabel.text = recipe?.ingredientsText!
        case 1:
            contentLabel.text = recipe?.text!
        default:
            break
        }
    }
    
    @IBAction func saveButtonPushed(_ sender: Any) {
        Task{
            if let id = recipe?.id {
                let result = await recipesService.saveRecipe(id: id)
                if result {
                    recipe?.isSaved = true
                    savedButton.alpha = 0.6
                }
            }
        }
        if recipe?.isSaved == true{
            recipe?.isSaved = false
            savedButton.alpha = 1
        }
    }
    
    //    @IBAction func deleteRecipe(_ sender: UIButton) {
    //        Task {
    //            if let id = recipeOld?.id {
    //                let result = await recipesService.deleteAsync(id: id)
    //                if result {
    //                    self.performSegue(withIdentifier: "unwindToRecipes", sender: self)
    //                }
    //            }
    //        }
    //    }
    
    //    @IBAction func unwindToRecipe( _ seg: UIStoryboardSegue) {
    //    }
}
    //MARK: - UITableViewDataSource
extension RecipeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(ingredients.count)
        
        return ingredients.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath) as! IngredientCell
        
        print("cell")
        
        let entity = ingredients[indexPath.row]
        cell.ingredientName?.text = entity.name
        cell.ingredientAmount?.text = String(entity.amount) + " " + entity.units!
        return cell
    }
//    func tableView(_ tableView: UITableView,
//               heightForRowAt indexPath: IndexPath) -> CGFloat {
//       // Make the first row larger to accommodate a custom cell.
//      if indexPath.row == 0 {
//          return 80
//       }
//
//       // Use the default size for all other rows.
//       return UITableView.automaticDimension
//    }
}

//MARK: - UITableViewDelegate
extension RecipeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        }
    }

