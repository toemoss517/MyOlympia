//
//  CircleView.swift
//  MyOlympia
//
//  Created by Michael Russo on 8/8/17.
//  Copyright © 2017 ToeMoss. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}
