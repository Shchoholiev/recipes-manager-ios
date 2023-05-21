//
//  ChooseCategoryViewController.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 1/22/23.
//

import UIKit

class ChooseCategoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchField: UITextField!
    
    let categoriesService = CategoriesService()
    
    var categories = [CategoryOld]()
    
    var currentPage = 1
    
    var totalPages = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        addPage(pageNumber: currentPage)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CategoryChooseCell", bundle: nil), forCellReuseIdentifier: "CategoryChooseCell")
        searchField.delegate = self
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
    
    var chooseCategoryCallback: ((_ category: CategoryOld) -> Void)? = nil
    
    @objc func chooseCategory(sender: UIView) {
        let chosenCategory = categories.first(where: { $0.id == sender.tag } )
        if let safeCategory = chosenCategory, let callback = chooseCategoryCallback {
            callback(safeCategory)
        }
        performSegue(withIdentifier: "unwindToAddRecipe", sender: self)
    }
    
    @objc func deleteCategory(sender: UIView) {
        let id = sender.tag
        Task {
            let succeeded = await categoriesService.deleteAsync(id: id)
            if succeeded {
                setPage(pageNumber: 1)
            }
        }
    }
}

//MARK: - UITableViewDataSource
extension ChooseCategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryChooseCell", for: indexPath) as! CategoryChooseCell
        let category = categories[indexPath.row]
        cell.categoryWrapper.tag = category.id
        cell.categoryName.text = category.name
        cell.categoryWrapper.setOnClickListener(action: chooseCategory)
        cell.deleteButton.tag = category.id
        cell.deleteButton.setOnClickListener(action: deleteCategory)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension ChooseCategoryViewController: UITableViewDelegate {
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
extension ChooseCategoryViewController: UITextFieldDelegate {
    
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

