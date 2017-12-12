//
//  SliderViewController.swift
//  Wall
//
//  Contains a slider, meant to be displayed as popover
//  APIs Used:
//      UISlider 1 - Controls cell size in wallViewController
//
//  Created by Nicolai Garcia on 12/10/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit

protocol SliderViewControllerDelegate {
    func sliderViewController(changedSizeTo widthDivider: Float)
}

class SliderViewController: UIViewController {
    
    @IBOutlet weak var sliderOutlet: UISlider! {
        didSet {
            sliderOutlet.value = lastValue ?? 0.0
        }
    }
        
    var lastValue: Float?
    
    var delegate: SliderViewControllerDelegate?
    
    @IBAction func slider(_ sender: UISlider) {
        delegate?.sliderViewController(changedSizeTo: sender.value)
    }

}
