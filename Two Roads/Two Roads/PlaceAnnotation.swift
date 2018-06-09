//
//  PlaceAnnotation.swift
//  Two Roads
//
//  Created by Avikant Saini on 6/9/18.
//  Copyright © 2018 tomato. All rights reserved.
//

import UIKit
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {

	let coordinate: CLLocationCoordinate2D
	let title: String?
	
	init(location: CLLocationCoordinate2D, title: String) {
		self.coordinate = location
		self.title = title
		
		super.init()
	}
	
}
