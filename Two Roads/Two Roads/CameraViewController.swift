//
//  CameraViewController.swift
//  Two Roads
//
//  Created by Avikant Saini on 6/9/18.
//  Copyright © 2018 tomato. All rights reserved.
//

import UIKit
import CoreLocation
import HDAugmentedReality

class CameraViewController: UIViewController {
	
	fileprivate var places = [Place]()
	fileprivate let locationManager = CLLocationManager()
	
	fileprivate var arController: ARViewController!
	
	fileprivate var loadedPOIs: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.startUpdatingLocation()
		locationManager.requestWhenInUseAuthorization()
		
		arController = ARViewController()
		
		arController.dataSource = self

//		arController.maxVisibleAnnotations = 45
//		arController.maxVerticalLevel = 5
//		arController.headingSmoothingFactor = 0.05
		
		arController.trackingManager.userDistanceFilter = 25
		arController.trackingManager.reloadDistanceFilter = 75
		
		arController.uiOptions.closeButtonEnabled = false
		
    }
	
	override func viewDidAppear(_ animated: Bool) {
//		self.present(arController, animated: false) {
//			self.tabBarController?.selectedIndex = 0
//		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.addChildViewController(arController)
		self.view.addSubview(arController.view)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		arController.view.removeFromSuperview()
		arController.removeFromParentViewController()
	}
	
	func showInfoView(forPlace place: Place) {
		let alert = UIAlertController(title: place.placeName , message: place.infoText, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		
		arController.present(alert, animated: true, completion: nil)
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension CameraViewController: CLLocationManagerDelegate {
	func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
		return true
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		if locations.count > 0 {
			let location = locations.last!
			if location.horizontalAccuracy < 100 {
				manager.stopUpdatingLocation()
//				let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
//				let region = MKCoordinateRegion(center: location.coordinate, span: span)
//				mapView.region = region
				
				if !loadedPOIs {
					loadedPOIs = true
					let loader = PlacesLoader()
					loader.loadPOIS(location: location, radius: 1000) { placesDict, error in
						if let dict = placesDict {
							guard let placesArray = dict.object(forKey: "results") as? [NSDictionary]  else { return }
							
							for placeDict in placesArray {
								let latitude = placeDict.value(forKeyPath: "geometry.location.lat") as! CLLocationDegrees
								let longitude = placeDict.value(forKeyPath: "geometry.location.lng") as! CLLocationDegrees
								let reference = placeDict.object(forKey: "reference") as! String
								let name = placeDict.object(forKey: "name") as! String
								let address = placeDict.object(forKey: "vicinity") as! String
								
								let location = CLLocation(latitude: latitude, longitude: longitude)
								if let place = Place(location: location, reference: reference, name: name, address: address) {
									self.places.append(place)
//									let annotation = PlaceAnnotation(location: place.location.coordinate, title: place.placeName)
//									DispatchQueue.main.async {
//										self.mapView.addAnnotation(annotation)
//									}
								}
							}
							DispatchQueue.main.async {
								self.arController.setAnnotations(self.places)
							}
						}
					}
				}
			}
		}
	}
}

extension CameraViewController: ARDataSource {
	func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
		let annotationView = Bundle.main.loadNibNamed("AnnotationView", owner: nil, options: nil)?.first as! AnnotationView
		annotationView.annotation = viewForAnnotation
		annotationView.delegate = self
		annotationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
		
		return annotationView
	}
}

extension CameraViewController: AnnotationViewDelegate {
	func didTouch(annotationView: AnnotationView) {
		if let annotation = annotationView.annotation as? Place {
			let placesLoader = PlacesLoader()
			placesLoader.loadDetailInformation(forPlace: annotation) { resultDict, error in
				
				if let infoDict = resultDict?.object(forKey: "result") as? NSDictionary {
					annotation.phoneNumber = infoDict.object(forKey: "formatted_phone_number") as? String
					annotation.website = infoDict.object(forKey: "website") as? String
					
					self.showInfoView(forPlace: annotation)
				}
			}
			
		}
	}
}

