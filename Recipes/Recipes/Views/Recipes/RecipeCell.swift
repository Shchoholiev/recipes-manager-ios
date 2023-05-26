//
//  TableViewCell.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/11/22.
//

import UIKit

class RecipeCell: UITableViewCell {
    
    weak var delegate: RecipeCellDelegate?

    @IBOutlet weak var recipeWrapper: UIView!
    
    @IBOutlet weak var recipeName: UILabel!
    
    @IBOutlet weak var recipeCategory: UILabel!
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    var recipeId: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        recipeWrapper.layer.cornerRadius = 10
        recipeWrapper.layer.borderWidth = 1
        recipeWrapper.layer.borderColor = CGColor(gray: 0.8, alpha: 1)
        recipeWrapper.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func cellTapped() {
        delegate?.recipeCellDidTap(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

protocol RecipeCellDelegate: AnyObject {
    func recipeCellDidTap(_ cell: RecipeCell)
}
