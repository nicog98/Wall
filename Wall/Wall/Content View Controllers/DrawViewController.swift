//
//  DrawViewController.swift
//  Wall
//
//  Drawing Pad View Controller, allows user to share/edit a drawing once done
//
//  APIs Used
//      CoreGraphics 2 - Follows finger movements and draws a line
//
//  Created by Nicolai Garcia on 11/28/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit
import CoreGraphics

protocol DrawViewControllerDelegate {
    func saveDrawing(drawingImageData: Data, aspectRatio: CGFloat, existingIndex: Int?)
}

class DrawViewController: UIViewController {
    
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    var delegate: DrawViewControllerDelegate?
    
    var existingDrawing: UIImage?
    
    var indexOfExistingDrawing: Int?
    
    // MARK: Sharing
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        let activityItems = [self.tempImageView.image as Any]
        let avc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.present(avc, animated: true, completion: nil)
    }
    
    // MARK: Drawing
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        
        context?.setLineCap(.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: opacity)
        context?.setBlendMode(.normal)
        
        context?.strokePath()
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
        }
        
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height),
                                  blendMode: .normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var tempImageView: UIImageView!
    
    // MARK: Navigation Bar Buttons
    
    @IBAction func close(_ sender: UIBarButtonItem?) {
        if mainImageView.image != nil {
            let aspectRatio = mainImageView.image!.size.height / mainImageView.image!.size.width
            delegate?.saveDrawing(drawingImageData: UIImageJPEGRepresentation(
                tempImageView.image!, 1.0)!,
                                  aspectRatio: aspectRatio,
                                  existingIndex: indexOfExistingDrawing)
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (existingDrawing != nil) {
            mainImageView.image = existingDrawing
            tempImageView.image = existingDrawing
        }
    }
    
}
