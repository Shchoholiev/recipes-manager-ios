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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func cellTapped() {
        print("tapped")
        delegate?.recipeCellDidTap(self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

protocol RecipeCellDelegate: AnyObject {
    func recipeCellDidTap(_ cell: RecipeCell)
}
