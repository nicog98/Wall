//
//  WallCollectionViewCell.swift
//  Wall
//
//  Collection View Cell to hold an image
//
//  Created by Nicolai Garcia on 11/27/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit

class ImageWallCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func fetchImage(_ imageURL: URL) {
        do {
            let contents = try Data(contentsOf: imageURL)
            imageView.image = UIImage(data: contents)
        } catch {
            print("Image Not Found")
            imageView.image = nil
        }
    }
    
}
