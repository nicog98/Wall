//
//  Post.swift
//  Wall
//
//  Post Model
//
//  Created by Nicolai Garcia on 11/27/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import Foundation

struct Post: Codable {
    
    var type: postType?
    
    var data: Data?
    
    var url: URL?
        
    var aspectRatio: Float?
    
    var latitude: Double?
    var longitude: Double?
    
    var textContent: String?
    
    var name: String?
    
    enum postType: String, Codable {
        case image
        case movie
        case drawing
        case text
        case song
        case file
    }
    
    init(_ postType: postType) {
        type = postType
        url = nil
        latitude = nil
        longitude = nil
        textContent = nil
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(Post.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    var json: Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            print("Error in encoding post")
            return nil
        }
    }
    
}
