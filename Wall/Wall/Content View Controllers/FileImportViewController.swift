//
//  SocialMediaImportViewController.swift
//  Wall
//
//  Created by Nicolai Garcia on 11/28/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit

class FileImportViewController: UIViewController {

    @IBAction func close(_ sender: UIBarButtonItem?) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(closeSwipe(_:)))
        swipe.direction = .down
        self.view.addGestureRecognizer(swipe)
    }
    
    @objc func closeSwipe(_ sender: UISwipeGestureRecognizer) {
        close(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
