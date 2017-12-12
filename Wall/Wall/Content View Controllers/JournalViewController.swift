//
//  JournalViewController.swift
//  Wall
//
//  Holds a journal entry, and allows users to share the inputted text.
//
//  Created by Nicolai Garcia on 11/28/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit

protocol JournalViewControllerDelegate: class {
    func savedText(text: String, existingIndex: Int?)
}

class JournalViewController: UIViewController, UITextViewDelegate {
    
    var delegate: JournalViewControllerDelegate?
    
    var indexOfExistingText: Int?
    
    var text: String?
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
        }
    }
    
    @IBAction func close(_ sender: UIBarButtonItem?) {
        delegate?.savedText(text: textView.text, existingIndex: indexOfExistingText)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        let activityItems = [self.textView.text as Any]
        let avc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.present(avc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(closeSwipe(_:)))
        swipe.direction = .down
        self.view.addGestureRecognizer(swipe)
        if text != nil {
            textView.text = text
        }
    }
    
    @objc func closeSwipe(_ sender: UISwipeGestureRecognizer) {
        close(nil)
    }

}
