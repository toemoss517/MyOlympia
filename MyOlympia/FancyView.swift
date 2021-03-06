//
//  FancyView.swift
//  MyOlympia
//
//  Created by Michael Russo on 8/6/17.
//  Copyright © 2017 ToeMoss. All rights reserved.
//

import UIKit

class FancyView: UIView {
    
    let SHADOW_GRAY: CGFloat = 120.0 / 255.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.cornerRadius = 3.0
    }
}
