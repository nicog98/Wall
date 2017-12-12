//
//  ImageViewController.swift
//  Wall
//
//  Presents an image and an option to share it.
//  APIs Used:
//      UIImageView 1
//      UISwipeGestureRecognizer 1 - Closes this view controller and segues back to wall view controller via modal presentation
//      UIActivityViewController 1 - Shares this image
//
//
//  Created by Nicolai Garcia on 11/29/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        let activityItems = [self.imageView.image as Any]
        let avc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.present(avc, animated: true, completion: nil)
    }
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        imageView.sizeToFit()
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDismiss(_:)))
        swipeDown.direction = .down
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeDismiss(_:)))
        swipeUp.direction = .up
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeDismiss(_:)))
        swipeRight.direction = .right
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeDismiss(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeDown)
        self.view.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func swipeDismiss(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

}
