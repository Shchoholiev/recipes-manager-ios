//
//  RecipesViewController.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/11/22.
//

import UIKit

class RecipesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var SearchTypesBar: UISegmentedControl!
    
    let recipesService = RecipesService()
    
    let helpersService = HelpersService()
    
    var recipesOld = [RecipeOld]()
    
    var recipes = [Recipe]()
    
    var currentPage = 1
    
    var totalPages = 1
    
    var chosenId: String?
    
    var searchType: RecipesSearchTypes = .PUBLIC

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "RecipeCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
        searchField.delegate = self
        SearchTypesBar.selectedSegmentIndex = searchType.rawValue
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setPage(pageNumber: 1)
    }
    
    func setPage(pageNumber: Int) {
        Task {
            let recipesPage =  await recipesService.getPageAsync(pageNumber: pageNumber, searchType: searchType, search: searchField.text ?? "")
            if let safePage = recipesPage {
                recipes = safePage.items
                currentPage = pageNumber
                totalPages = safePage.totalPages
                tableView.reloadData()
            } else {
                recipes = []
                currentPage = pageNumber
                totalPages = 0
                tableView.reloadData()
            }
        }
    }
    
    func addPage(pageNumber: Int) {
        Task {
            let recipesPage =  await recipesService.getPageAsync(pageNumber: pageNumber, searchType: searchType, search: searchField.text ?? "")
            if let safePage = recipesPage {
                recipes.append(contentsOf: safePage.items)
                tableView.reloadData()
            }
        }
    }

//    func search(pageNumber: Int, filter: String) {
//        Task {
//            let recipesPage =  await recipesService.getPageAsync(pageNumber: pageNumber, filter: filter)
//            if let safePage = recipesPage {
//                recipesOld = safePage.items
//                totalPages = safePage.pagesCount
//                currentPage = pageNumber
//                tableView.reloadData()
//            }
//        }
//    }
//
//    func addSearchPage(pageNumber: Int, filter: String) {
//        Task {
//            let recipesPage =  await recipesService.getPageAsync(pageNumber: pageNumber, filter: filter)
//            if let safePage = recipesPage {
//                recipesOld.append(contentsOf: safePage.items)
//                tableView.reloadData()
//            }
//        }
//    }
    
    @objc func showRecipe(_ id: String) {
        chosenId = id
        self.performSegue(withIdentifier: "showRecipe", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showRecipe":
            let view = segue.destination as! RecipeViewController
            view.id = chosenId
        default:
            break
        }
    }
    
    @IBAction func SearchTypeChanged(_ sender: UISegmentedControl) {
        let chosenIndex = sender.selectedSegmentIndex
        print(chosenIndex)
        if let type = RecipesSearchTypes(rawValue: chosenIndex) {
            searchType = type
        }
        setPage(pageNumber: 1);
    }
    
    @IBAction func unwindToRecipes( _ seg: UIStoryboardSegue) {
        setPage(pageNumber: 1)
    }
}

//MARK: - UITableViewDataSource
extension RecipesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        let recipe = recipes[indexPath.row]
        cell.recipeName.text = recipe.name
        cell.recipeCategory.text = recipe.categories[0].name
        cell.recipeId = recipe.id
        Task {
            if let thumbnail = recipe.thumbnail {
//                let imageData = await helpersService.downloadImage(from: thumbnail)
//                if let safeData = imageData {
//                    cell.thumbnail.contentMode = .scaleAspectFill
//                    cell.thumbnail.image = UIImage(data: safeData)
//                } else {
//                    cell.thumbnail.contentMode = .center
//                    cell.thumbnail.image = UIImage(systemName: "photo")
//                }
            } else {
                cell.thumbnail.contentMode = .center
                cell.thumbnail.image = UIImage(systemName: "photo")
            }
        }
        
        return cell
    }
}

//MARK: - UITextFieldDelegate
extension RecipesViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        setPage(pageNumber: 1)
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

//MARK: - UITableViewDelegate
extension RecipesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = recipes.count - 1
        if indexPath.row == lastItem {
            if currentPage < totalPages {
                currentPage += 1
                addPage(pageNumber: currentPage)
            }
        }
    }
}

//MARK: - RecipeCellDelegate
extension RecipesViewController: RecipeCellDelegate {
    func recipeCellDidTap(_ cell: RecipeCell) {
        showRecipe(cell.recipeId)
    }
}
