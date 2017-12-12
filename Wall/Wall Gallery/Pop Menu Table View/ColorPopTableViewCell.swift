//
//  ColorPopTableViewCell.swift
//  Wall
//
//  Table View Cell that contains color options for a wall
//
//
//  Created by Nicolai Garcia on 12/9/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit

protocol ColorPopTableViewCellDelegate {
    func colorPopTableViewCell(choseColor color: UIColor)
}

class ColorPopTableViewCell: UITableViewCell {
    
    var delegate: ColorPopTableViewCellDelegate?
    
    var colors: [UIColor] = [#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1),#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),#colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1),#colorLiteral(red: 0.3221543049, green: 0.8253108693, blue: 0.4237220635, alpha: 1),#colorLiteral(red: 1, green: 0.9636610316, blue: 0.899808668, alpha: 1)]
    
    @IBOutlet var colorButtons: [UIButton]! {
        didSet {
            for colorButtonIndex in colorButtons.indices {
                colorButtons[colorButtonIndex].backgroundColor = colors[colorButtonIndex]
            }
        }
    }
    
    @IBAction func choseColor(_ sender: UIButton) {
        if let color = sender.backgroundColor {
            delegate?.colorPopTableViewCell(choseColor: color)
        }
    }

}
