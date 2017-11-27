//
//  Post.swift
//  Wall
//
//  Created by Nicolai Garcia on 11/27/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import Foundation

struct Post {
    
    var type: postType = .photo
    
    var url: URL?
    
    var aspectRatio: Float?
    
    enum postType {
        case photo
        case text
        case drawing
        case song
        case album
    }
    
}
