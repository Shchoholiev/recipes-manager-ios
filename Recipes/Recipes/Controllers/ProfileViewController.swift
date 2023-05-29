//
//  ProfileViewController.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/28/23.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    let usersServise = UsersService()
    
    let recipesService = RecipesService()
    
    let helpersService = HelpersService()
    
    var user: User?
    
    var recipes = [Recipe]()
    
    var currentPage = 1
    
    var totalPages = 1
    
    var chosenId: String?
    
    var searchType: RecipesSearchTypes = .PERSONAL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RecipeCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
        
        nameTextField.isEnabled = false
        phoneTextField.isEnabled = false
        emailTextField.isEnabled = false
        Task{
            let user = await self.usersServise.getCurrentUserAsync()
            if let safeUser = user{
                nameTextField.placeholder = safeUser.name
                phoneTextField.placeholder = safeUser.phone
                emailTextField.placeholder = safeUser.email
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nameTextField.text = GlobalUser.shared.name
        setPage(pageNumber: 1)
    }
    
    func setPage(pageNumber: Int) {
        Task {
            if let safeId = GlobalUser.shared.id{
                let recipesPage = await recipesService.getPageAsync(pageNumber: pageNumber, searchType: searchType, search: "", authorId: safeId)
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
    }
    
    func addPage(pageNumber: Int) {
        Task {
            if let safeId = GlobalUser.shared.id{
                let recipesPage = await recipesService.getPageAsync(pageNumber: pageNumber, searchType: searchType, search: "", authorId: safeId)
                if let safePage = recipesPage {
                    recipes.append(contentsOf: safePage.items)
                    totalPages = safePage.totalPages
                    tableView.reloadData()
                }
            }
        }
    }
}



//MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
//        cell.delegate = self
        let recipe = recipes[indexPath.row]
        cell.recipeName.text = recipe.name
        if !recipe.categories.isEmpty {
            cell.recipeCategory.text = recipe.categories[0].name
        }
        cell.recipeId = recipe.id
        Task {
            if let thumbnail = recipe.thumbnail {
                let imageData = await helpersService.downloadImage(from: "https://l7l2.c16.e2-2.dev/recipes/" + thumbnail.smallPhotoGuid! + "." + thumbnail.extension!)
                if let safeData = imageData {
                    cell.thumbnail.contentMode = .scaleAspectFill
                    cell.thumbnail.image = UIImage(data: safeData)
                } else {
                    cell.thumbnail.contentMode = .center
                    cell.thumbnail.image = UIImage(systemName: "photo")
                }
            } else {
                cell.thumbnail.contentMode = .center
                cell.thumbnail.image = UIImage(systemName: "photo")
            }
        }
        
        return cell
    }
    
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
}



//MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == recipes.count - 3 {
            if currentPage < totalPages {
                currentPage += 1
                addPage(pageNumber: currentPage)
            }
        }
    }
}

//MARK: - ProfileCellDelegate
extension ProfileViewController: RecipeCellDelegate {
    func recipeCellDidTap(_ cell: RecipeCell) {
        showRecipe(cell.recipeId)
    }
}
