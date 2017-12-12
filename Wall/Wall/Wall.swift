//
//  Wall.swift
//  Wall
//
//  Wall Model
//
//  Created by Nicolai Garcia on 11/27/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import Foundation

struct Wall: Codable {
    
    var name: String?
    
    var description: String?
    
    var posts: [Post] = []
    
    var wallIndex: Int?
    
    var colorValues: [Float]?
    
    var dateCreated: Date?
    
    var steps: Int?
    
    init() {
        name = nil
        posts = []
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(Wall.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    var json: Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            print("Error in encoding wall")
            return nil
        }
    }
    
}
