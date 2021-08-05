//
//  CustomButtons.swift
//  Winter Basketball AR
//
//  Created by Vladislav Vitsenets on 8/02/21.
//  Copyright © 2021 Vladislav Vitsenets. All rights reserved.
//

import UIKit

class CustomButtons: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeButtons()
    }
    
    func customizeButtons() {
        backgroundColor = UIColor.cyan
        layer.cornerRadius = 11.0
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.white.cgColor
    }

}
