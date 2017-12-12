//
//  MovieCollectionViewCell.swift
//  Wall
//
//  Collection View Cell to hold a video,
//  and generate a thumbnail image for that video
//
//  APIs Used:
//      AVAsset 1 - Used to store a video as AVAsset and create a thumbnail representation for the video
//
//  Created by Nicolai Garcia on 11/29/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit
import AVFoundation

class MovieWallCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var movieURL: URL? {
        didSet {
            imageView.image = thumbnailForVideoAtURL(movieURL!)
        }
    }
    
    private func thumbnailForVideoAtURL(_ url: URL) -> UIImage {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try? assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef!)
        }
    }
    
}
