//
//  FancyField.swift
//  MyOlympia
//
//  Created by Michael Russo on 8/6/17.
//  Copyright © 2017 ToeMoss. All rights reserved.
//

import UIKit

class FancyField: UITextField {
    
    let SHADOW_GRAY: CGFloat = 120.0 / 255.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.4).cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 3.0
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {       
        return bounds.insetBy(dx: 10, dy: 5)
    }
}
