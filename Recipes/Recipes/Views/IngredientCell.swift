//
//  IngredientCell.swift
//  Recipes
//
//  Created by Vitalii Krasnorutskyi on 25.05.23.
//

import UIKit

class IngredientCell: UITableViewCell {
    
    @IBOutlet weak var ingredientWrapper: UIView!
    
    @IBOutlet weak var ingredientName: UILabel!
    
    @IBOutlet weak var ingredientAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ingredientWrapper.layer.cornerRadius = 10
        ingredientWrapper.layer.borderWidth = 1
        ingredientWrapper.layer.borderColor = CGColor(gray: 0.8, alpha: 1)
        ingredientWrapper.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}


