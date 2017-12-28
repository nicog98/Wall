//
//  WallDocument.swift
//  Wall
//
//  Created by Nicolai Garcia on 12/1/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit

class WallDocument: UIDocument {
    
    var wall: Wall?
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let json = contents as? Data {
            wall = Wall(json: json)
            if wall == nil {
                wall = Wall()
            }
        }
    }

    override func contents(forType typeName: String) throws -> Any {
        return wall?.json ?? Data()
    }
     
}
