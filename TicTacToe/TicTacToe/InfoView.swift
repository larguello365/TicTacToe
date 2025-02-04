//
//  InfoView.swift
//  TicTacToe
//
//  Created by Lester Arguello on 2/3/25.
//

import UIKit

class InfoView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.gray.cgColor
        self.clipsToBounds = true
    }
    

}
