//
//  ViewController.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/6/22.
//

import UIKit

class CategoriesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchField: UITextField!
    
    let categoriesService = CategoriesService()
    
    var categories = [Category]()
    
    var currentPage = 1
    
    var totalPages = 1
    
    var chosenCategory: Category?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        searchField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setPage(pageNumber: currentPage)
    }
    
    func setPage(pageNumber: Int) {
        Task {
            let categoriesPage =  await categoriesService.getPageAsync(pageNumber: pageNumber)
            if let safePage = categoriesPage {
                categories = safePage.items
                currentPage = pageNumber
                totalPages = safePage.pagesCount
                tableView.reloadData()
            }
        }
    }
    
    func addPage(pageNumber: Int) {
        Task {
            let categoriesPage =  await categoriesService.getPageAsync(pageNumber: pageNumber)
            if let safePage = categoriesPage {
                categories.append(contentsOf: safePage.items)
                totalPages = safePage.pagesCount
                tableView.reloadData()
            }
        }
    }
    
    func search(pageNumber: Int, filter: String) {
        Task {
            let categoriesPage = await categoriesService.getPageAsync(pageNumber: pageNumber, filter: filter)
            if let safePage = categoriesPage {
                categories = safePage.items
                currentPage = pageNumber
                totalPages = safePage.pagesCount
                tableView.reloadData()
            }
        }
    }
    
    func addSearchPage(pageNumber: Int, filter: String) {
        Task {
            let categoriesPage =  await categoriesService.getPageAsync(pageNumber: pageNumber, filter: filter)
            if let safePage = categoriesPage {
                categories.append(contentsOf: safePage.items)
                tableView.reloadData()
            }
        }
    }
    
    @objc func showRecipesByCategory(sender: UIView) {
        chosenCategory = categories.first(where: { $0.id == sender.tag } )
        self.performSegue(withIdentifier: "showRecipesByCategory", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showRecipesByCategory":
            let view = segue.destination as! RecipesByCategoryViewController
            view.category = chosenCategory
        default:
            break
        }
    }
}

//MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let category = categories[indexPath.row]
        cell.categoryWrapper.tag = category.id
        cell.categoryName.text = category.name
        cell.categoryWrapper.setOnClickListener(action: showRecipesByCategory)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = categories.count - 1
        if indexPath.row == lastItem {
            if currentPage < totalPages {
                currentPage += 1
                addPage(pageNumber: currentPage)
            }
        }
    }
}

//MARK: - UITextFieldDelegate
extension CategoriesViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let filter = searchField.text {
            currentPage = 1
            if filter.isEmpty {
                setPage(pageNumber: currentPage)
            } else {
                search(pageNumber: currentPage, filter: filter)
            }
        }
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
}
