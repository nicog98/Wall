//
//  PopMenuViewController.swift
//  Wall
//
//  View Controller presented as popover. Provides an initial menu for creating
//  a wall with a specific color and name
//
//  APIs Used:
//      UITableView 2 - second instance of TableView to store a text field for wall's name and a color for its theme
//
//
//  Created by Nicolai Garcia on 12/9/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit

protocol PopMenuTableViewControllerDelegate {
    func wallAdded(withName name: String, withColor color: UIColor)
}

class PopMenuTableViewController: UITableViewController, NamePopTableViewCellDelegate, ColorPopTableViewCellDelegate {

    var delegate: PopMenuTableViewControllerDelegate?
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath)
            if let nameCell = cell as? NamePopTableViewCell {
                nameCell.delegate = self
            }
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "colorCell", for: indexPath)
            if let colorCell = cell as? ColorPopTableViewCell {
                colorCell.delegate = self
            }
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }

    // MARK: Delegates
    
    var chosenName: String?
    var chosenColor: UIColor?
    
    func colorPopTableViewCell(choseColor color: UIColor) {
        chosenColor = color
        if chosenName != nil {
            delegate?.wallAdded(withName: chosenName!, withColor: chosenColor!)
            self.presentationController?.presentedViewController.dismiss(animated: true)
        }
    }
    
    func namePopTableViewCell(choseName name: String) {
        chosenName = name
        if chosenColor != nil {
            delegate?.wallAdded(withName: chosenName!, withColor: chosenColor!)
            self.presentationController?.presentedViewController.dismiss(animated: true)
        }
    }

}
