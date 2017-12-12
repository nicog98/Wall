//
//  MapViewController.swift
//  Wall
//
//  Displays a Map with annotations of where items were added
//
//  APIs Used:
//      MKMapView 2 - Displays a map and annotations
//      MKAnnotationView 1 - Holds an annotation for where an object was added to the wall
//
//  Created by Nicolai Garcia on 12/2/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import MapKit
import UIKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    var posts: [Post]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        for postIndex in (posts?.indices)! {
            let post = posts![postIndex]
            if let latitude = post.latitude, let longitude = post.longitude {
                mapView.addAnnotation(Annotation(latitude: latitude, longitude: longitude, index: postIndex))
            }
        }
    }
    
    func fetchImage(imageURL: URL) -> UIImage? {
        var image: UIImage?
        DispatchQueue.global(qos: .userInitiated).async {
            let contents = try? Data(contentsOf: imageURL)
            DispatchQueue.main.async {
                image = UIImage(data: contents!)
            }
        }
        return image
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView()
        if let a = annotation as? Annotation {
            if let post = posts?[a.index!] {
                if post.data != nil {
                    annotationView.image = UIImage(data: post.data!)
                } else if post.url != nil {
                    annotationView.image = fetchImage(imageURL: post.url!)
                }
            }
        }
        return annotationView
    }

}
