//
//  PlacesLoader.swift
//  Two Roads
//
//  Created by Avikant Saini on 6/9/18.
//  Copyright © 2018 tomato. All rights reserved.
//

import Foundation
import CoreLocation

struct PlacesLoader {
	
	// Load from google maps...
	
	let apiURL = "https://maps.googleapis.com/maps/api/place/"
	let apiKey = "AIzaSyB2ihsQhHNr_QkqUCPCuz9PPCWRMBzjeLo"
	
	func loadPOIS(location: CLLocation, radius: Int = 100, handler: @escaping (NSDictionary?, NSError?) -> Void) {
		print("Load pois")
		let latitude = location.coordinate.latitude
		let longitude = location.coordinate.longitude
		
		let uri = apiURL + "nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&sensor=true&types=cafe&key=\(apiKey)"
		
		let url = URL(string: uri)!
		let session = URLSession(configuration: URLSessionConfiguration.default)
		let dataTask = session.dataTask(with: url) { data, response, error in
			if let error = error {
				print(error)
			} else if let httpResponse = response as? HTTPURLResponse {
				if httpResponse.statusCode == 200 {
					print(data!)
					
					do {
						let responseObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
						guard let responseDict = responseObject as? NSDictionary else {
							return
						}
						
						handler(responseDict, nil)
						
					} catch let error as NSError {
						handler(nil, error)
					}
				}
			}
		}
		
		dataTask.resume()
	}
	
	func loadDetailInformation(forPlace: Place, handler: @escaping (NSDictionary?, NSError?) -> Void) {
		
		let uri = apiURL + "details/json?reference=\(forPlace.reference)&sensor=true&key=\(apiKey)"
		
		let url = URL(string: uri)!
		let session = URLSession(configuration: URLSessionConfiguration.default)
		let dataTask = session.dataTask(with: url) { data, response, error in
			if let error = error {
				print(error)
			} else if let httpResponse = response as? HTTPURLResponse {
				if httpResponse.statusCode == 200 {
					print(data!)
					
					do {
						let responseObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
						guard let responseDict = responseObject as? NSDictionary else {
							return
						}
						
						handler(responseDict, nil)
						
					} catch let error as NSError {
						handler(nil, error)
					}
				}
			}
		}
		
		dataTask.resume()
		
	}
}
