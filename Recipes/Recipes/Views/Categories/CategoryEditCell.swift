//
//  CategoryEditCell.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 1/27/23.
//

import UIKit

class CategoryEditCell: UITableViewCell {

    @IBOutlet weak var categoryWrapper: UIView!
    
    @IBOutlet weak var categoryName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryWrapper.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
