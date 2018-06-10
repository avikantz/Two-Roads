//
//  Place.swift
//  Two Roads
//
//  Created by Avikant Saini on 6/9/18.
//  Copyright © 2018 tomato. All rights reserved.
//

import UIKit
import CoreLocation
import HDAugmentedReality

class Place: ARAnnotation {
	
	let reference: String
	let placeName: String
	let address: String
	var phoneNumber: String?
	var website: String?
	var types: String?
	
	var infoText: String {
		get {
			var info = "Address: \(address)"
			
			if phoneNumber != nil {
				info += "\nPhone: \(phoneNumber!)"
			}
			
			if website != nil {
				info += "\nweb: \(website!)"
			}
			return info
		}
	}
	
	init?(location: CLLocation, reference: String, name: String, address: String, types: String) {
		placeName = name
		self.reference = reference
		self.address = address
		self.types = types
		
		super.init(identifier: reference, title: name, location: location)
	}
	
	override var description: String {
		return placeName
	}

}
