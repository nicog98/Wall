//
//  WallGalleryDocument.swift
//  Wall
//
//  A document representing all of the walls and their data.
//
//  Created by Nicolai Garcia on 12/1/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit

class WallGalleryDocument: UIDocument {
    
    var wallGallery: WallGallery?
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let json = contents as? Data {
            wallGallery = WallGallery(json: json)
            if wallGallery == nil {
                wallGallery = WallGallery()
            }
        }
    }
    
    override func contents(forType typeName: String) throws -> Any {
        return wallGallery?.json ?? Data()
    }
 

}
