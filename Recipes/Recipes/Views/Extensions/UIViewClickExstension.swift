//
//  Extensions.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/11/22.
//

import UIKit

class ClickListener: UITapGestureRecognizer {
    var onClick : ((_ sender: UIView) -> Void)? = nil
}

extension UIView {
    
    func setOnClickListener(action :@escaping (_ view: UIView) -> Void){
        let tapRecogniser = ClickListener(target: self, action: #selector(onViewClicked(sender:)))
        tapRecogniser.onClick = action
        self.addGestureRecognizer(tapRecogniser)
    }
     
    @objc func onViewClicked(sender: ClickListener) {
        if let onClick = sender.onClick {
            onClick(self)
        }
    }
     
}
