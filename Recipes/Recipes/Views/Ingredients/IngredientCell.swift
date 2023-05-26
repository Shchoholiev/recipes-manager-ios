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
        ingredientWrapper.layer.backgroundColor = CGColor(gray: 0.85, alpha: 0.35)
        ingredientWrapper.layer.borderColor = CGColor(gray: 0.15, alpha: 1)
        ingredientWrapper.clipsToBounds = true
    }
}


