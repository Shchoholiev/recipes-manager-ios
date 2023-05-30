//
//  CategoryCell.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/6/22.
//

import UIKit

class CategoryChooseCell: UITableViewCell {
    
    weak var delegate: CategoryChooseCellDelegate?
    
    @IBOutlet weak var categoryWrapper: UIView!
    
    @IBOutlet weak var categoryName: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    var category: Category?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryWrapper.layer.cornerRadius = 10
        categoryWrapper.layer.backgroundColor = CGColor(gray: 0.6, alpha: 0.1)
        categoryWrapper.layer.borderColor = nil
        categoryWrapper.layer.borderWidth = 0
    }
    
    func setValues() -> Void {
        categoryName.text = category?.name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func deleteClick(_ sender: UIButton) {
        delegate?.categoryDeleteDidTap(self)
    }
    
}

//MARK: - CategoryChooseCellDelegate
protocol CategoryChooseCellDelegate: AnyObject {
    func categoryDeleteDidTap(_ cell: CategoryChooseCell)
}
