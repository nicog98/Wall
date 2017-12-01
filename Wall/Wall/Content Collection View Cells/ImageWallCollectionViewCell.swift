//
//  WallCollectionViewCell.swift
//  Wall
//
//  Created by Nicolai Garcia on 11/27/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit

class ImageWallCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func fetchImage(_ imageURL: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let contents = try? Data(contentsOf: imageURL)
            DispatchQueue.main.async {
                if let imageData = contents {
                    self?.imageView.image = UIImage(data: imageData)
                }
            }
        }
        
    }
    
}
