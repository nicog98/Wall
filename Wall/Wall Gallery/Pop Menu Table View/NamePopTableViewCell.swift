//
//  NamePopTableViewCell.swift
//  Wall
//
//  Table View Cell with a text view to write and associate a name with a wall
//
//  APIs Used:
//      UITextField
//
//  Created by Nicolai Garcia on 12/9/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit

protocol NamePopTableViewCellDelegate {
    func namePopTableViewCell(choseName name: String)
}

class NamePopTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var delegate: NamePopTableViewCellDelegate?
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isEnabled = false
        delegate?.namePopTableViewCell(choseName: textField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
