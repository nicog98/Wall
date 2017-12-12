//
//  Annotation.swift
//  Wall
//
//  An object that holds an MKAnnotation
//
//  APIs Used:
//      MKAnnotation 1
//      CLLocationCoordinate2D 1 - stores the location coupled to the MKAnnotation
//
//  Created by Nicolai Garcia on 12/2/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import Foundation
import MapKit

class Annotation: NSObject, MKAnnotation {
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, index: Int) {
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.index = index
    }
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    // TODO: add init with index of post in posts
    
    var index: Int?
    
}
