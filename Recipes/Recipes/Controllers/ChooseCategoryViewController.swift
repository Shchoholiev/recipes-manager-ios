//
//  ChooseCategoryViewController.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 1/22/23.
//

import UIKit

class ChooseCategoryViewController: UIViewController {
    
    @IBOutlet weak var categoryName: UITextField!
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchField: UITextField!
    
    let categoriesService = CategoriesService()
    
    var categories = [Category]()
    
    var chosenCategories = [Category]()
    
    var currentPage = 1
    
    var totalPages = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        setPage(pageNumber: currentPage)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        searchField.delegate = self
    }
    
    func setPage(pageNumber: Int) {
        Task {
            let categoriesPage =  await categoriesService.getPageAsync(pageNumber: pageNumber)
            if let safePage = categoriesPage {
                categories = safePage.items
                currentPage = pageNumber
                totalPages = safePage.totalPages
                tableView.reloadData()
            } else {
                categories = []
                currentPage = pageNumber
                totalPages = 0
                tableView.reloadData()
            }
        }
    }
    
    func addPage(pageNumber: Int) {
        Task {
            let categoriesPage =  await categoriesService.getPageAsync(pageNumber: pageNumber)
            if let safePage = categoriesPage {
                categories.append(contentsOf: safePage.items)
                totalPages = safePage.totalPages
                tableView.reloadData()
            }
        }
    }
    
    func search(pageNumber: Int, filter: String) {
        Task {
//            let categoriesPage = await categoriesService.getPageAsync(pageNumber: pageNumber, filter: filter)
//            if let safePage = categoriesPage {
//                categories = safePage.items
//                currentPage = pageNumber
//                totalPages = safePage.pagesCount
//                tableView.reloadData()
//            }
        }
    }
    
    func addSearchPage(pageNumber: Int, filter: String) {
//        Task {
//            let categoriesPage =  await categoriesService.getPageAsync(pageNumber: pageNumber, filter: filter)
//            if let safePage = categoriesPage {
//                categories.append(contentsOf: safePage.items)
//                tableView.reloadData()
//            }
//        }
    }
    
    var chooseCategoryCallback: ((_ category: Category) -> Void)? = nil
    
    @IBAction func createButtonClicked(_ sender: UIButton) {
        createButton.isEnabled = false
        if let name = categoryName.text, !name.isEmpty {
            let category = Category(id: "", name: name)
            Task {
                let result = await categoriesService.createCategory(category)
                if let newCategory = result {
                    chosenCategories.append(newCategory)
                    if let chooseCallback = chooseCategoryCallback {
                        chooseCallback(newCategory)
                    }
                    reset()
                }
            }
        } else {
            showAlert(title: "Name is missing", message: "Please enter category name.")
        }
    }
    
    @objc func deleteCategory(sender: UIView) {
//        let id = sender.tag
//        Task {
//            let succeeded = await categoriesService.deleteAsync(id: id)
//            if succeeded {
//                setPage(pageNumber: 1)
//            }
//        }
    }
    
    func showAlert(title: String, message: String) {
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        dialogMessage.addAction(ok)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func reset() {
        categoryName.text = nil
        createButton.isEnabled = true
        setPage(pageNumber: 1)
        tableView.reloadData()
    }
}

//MARK: - UITableViewDataSource
extension ChooseCategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let category = categories[indexPath.row]
        cell.category = category
        cell.delegate = self
        cell.setValues()
        
        if chosenCategories.contains(where: { $0.id == category.id }) {
            cell.categoryWrapper.backgroundColor = UIColor(named: "AccentColor")
        } else {
            cell.categoryWrapper.backgroundColor = UIColor.clear
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension ChooseCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == categories.count - 3 {
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

//MARK: - CategoryCellDelegate
extension ChooseCategoryViewController: CategoryCellDelegate {
    
    func categoryCellDidTap(_ cell: CategoryCell) {
        if let category = cell.category {
            if let chooseCallback = chooseCategoryCallback {
                chooseCallback(category)
            }
            if let index = chosenCategories.firstIndex(where: { $0.id == category.id }) {
                chosenCategories.remove(at: index)
                cell.categoryWrapper.backgroundColor = UIColor.clear
            } else {
                chosenCategories.append(category)
                cell.categoryWrapper.backgroundColor = UIColor(named: "AccentColor")
            }
        }
    }
}

