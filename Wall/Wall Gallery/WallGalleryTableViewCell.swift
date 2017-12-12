//
//  WallGalleryTableViewCell.swift
//  Wall
//
//  Cell Representing a wall with the first image held in that wall,
//  the wall's name, and a short description about the wall.
//
//  Created by Nicolai Garcia on 11/27/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit

protocol WallGalleryTableViewCellDelegate: class {
    func longPress(longPressDelegatedFrom cell: WallGalleryTableViewCell)
    func tap(tapDelegatedFrom cell: WallGalleryTableViewCell)
    func descriptionEdited(descriptionEditedOn cell: WallGalleryTableViewCell)
}

class WallGalleryTableViewCell: UITableViewCell, UITextFieldDelegate, UITextViewDelegate {
    
    var delegate: WallGalleryTableViewCellDelegate?
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
            textView.keyboardType = .alphabet
        }
    }
    
    @IBOutlet weak var headerImage: UIImageView!
    
    var resignationHandler: (() -> Void)?
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isEnabled = false
        resignationHandler?()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    private var textFont: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(WallGalleryTableViewCell.constants.fontSize))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.font = textFont
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPressRecognizer.minimumPressDuration = WallGalleryTableViewCell.constants.timeInterval
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        self.addGestureRecognizer(longPressRecognizer)
        self.addGestureRecognizer(tapRecognizer)
        textField.isEnabled = false
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        delegate?.longPress(longPressDelegatedFrom: self)
        textField.text = ""
        textField.isEnabled = true
        textField.becomeFirstResponder()
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        delegate?.tap(tapDelegatedFrom: self)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            delegate?.descriptionEdited(descriptionEditedOn: self)
            return false
        }
        return true
    }

}

extension WallGalleryTableViewCell {
    private struct constants {
        static let fontSize: CGFloat = 30.0
        static let timeInterval: CFTimeInterval = 0.5
    }
}
