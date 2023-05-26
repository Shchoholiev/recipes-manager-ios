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
        ingredientWrapper.layer.backgroundColor = CGColor(gray: 0.6, alpha: 0.1)
        ingredientWrapper.layer.borderColor = nil
        ingredientWrapper.layer.borderWidth = 0
        ingredientWrapper.clipsToBounds = true
    }
}


