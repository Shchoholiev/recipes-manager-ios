//
//  TableViewCell.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/11/22.
//

import UIKit

class RecipeCell: UITableViewCell {

    @IBOutlet weak var recipeWrapper: UIView!
    
    @IBOutlet weak var recipeName: UILabel!
    
    @IBOutlet weak var recipeCategory: UILabel!
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        recipeWrapper.layer.cornerRadius = 10
        recipeWrapper.layer.borderWidth = 1
        recipeWrapper.layer.borderColor = CGColor(gray: 0.8, alpha: 1)
        recipeWrapper.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
