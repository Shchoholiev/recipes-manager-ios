//
//  ButtonCell.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/26/23.
//

import UIKit

class ButtonCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonClick(_ sender: UIButton) {
        if let function = onClick {
            function(sender)
        }
    }
    
    var onClick: ((_ sender: UIButton) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
