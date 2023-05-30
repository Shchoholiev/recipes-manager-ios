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
    
    var ingredient: Ingredient? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ingredientWrapper.layer.cornerRadius = 10
        ingredientWrapper.layer.borderWidth = 1
        ingredientWrapper.layer.backgroundColor = CGColor(gray: 0.6, alpha: 0.1)
        ingredientWrapper.layer.borderColor = nil
        ingredientWrapper.layer.borderWidth = 0
        ingredientWrapper.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set initial position of the cell outside the screen
    }
    
    func render() {
        if let safeIngredient = ingredient {
            ingredientName?.text = safeIngredient.name
            
            var amountText = ""
            
            if let calories = safeIngredient.totalCalories {
                amountText += "\(calories) ccal"
                if safeIngredient.amount != nil || safeIngredient.units != nil {
                    amountText += "  |  "
                }
            }
            
            if let amount = safeIngredient.amount {
                let numberFormatter = NumberFormatter()
                numberFormatter.minimumFractionDigits = 0
                numberFormatter.maximumFractionDigits = amount.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1
                let amountString = numberFormatter.string(from: NSNumber(value: amount))
                if let safeAmount = amountString {
                    amountText += safeAmount
                }
            }
            
            if let units = safeIngredient.units {
                amountText += " \(units)"
            }
            
            ingredientAmount.text = amountText
        }
    }
    
    func animate() {
        transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}


