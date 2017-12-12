//
//  WallGallery.swift
//  Wall
//
//  Wall Gallery Model. Contains metadata for the user's walls
//
//  Created by Nicolai Garcia on 11/27/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import Foundation

struct WallGallery: Codable {
        
    var walls: [Wall] = []
    
    init() {
        walls = []
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(WallGallery.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    var json: Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            print("Error in encoding wall gallery")
            return nil
        }
    }
    
}
