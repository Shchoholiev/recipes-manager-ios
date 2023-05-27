//
//  CategoryCell.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/6/22.
//

import UIKit

class CategoryCell: UITableViewCell {
    
    weak var delegate: CategoryCellDelegate?
    
    @IBOutlet weak var categoryWrapper: UIView!
    
    @IBOutlet weak var categoryName: UILabel!
    
    var category: Category? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryWrapper.layer.cornerRadius = 10
        categoryWrapper.layer.borderWidth = 1
        categoryWrapper.layer.borderColor = CGColor(gray: 0.8, alpha: 1)
        categoryWrapper.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func cellTapped() {
        delegate?.categoryCellDidTap(self)
    }
}

//MARK: - CategoryCellDelegate
protocol CategoryCellDelegate: AnyObject {
    func categoryCellDidTap(_ cell: CategoryCell)
}
