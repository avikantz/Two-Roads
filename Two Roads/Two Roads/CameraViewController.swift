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
	
	var singlePlace: Place?
	
	fileprivate var places = [Place]()
	fileprivate let locationManager = CLLocationManager()
	
	fileprivate var arController: ARViewController!
	
	fileprivate var loadedPOIs: Bool = false
	

    override func viewDidLoad() {
        super.viewDidLoad()
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		
		arController = ARViewController()
		
		arController.dataSource = self
		
		arController.trackingManager.userDistanceFilter = 25
		arController.trackingManager.reloadDistanceFilter = 75

		arController.trackingManager.pitchFilterFactor = 0.9
		arController.trackingManager.headingFilterFactor = 0.9

		
		arController.presenter.maxDistance = 3000               // Don't show annotations if they are farther than this
		arController.presenter.maxVisibleAnnotations = 30
		arController.presenter.distanceOffsetMultiplier = 0.01
		arController.presenter.distanceOffsetMinThreshold = 500
		arController.presenter.bottomBorder = 0.4
		arController.presenter.presenterTransform = ARPresenterStackTransform.init()
		
		arController.uiOptions.closeButtonEnabled = false
		
    }
	
//	override func viewDidAppear(_ animated: Bool) {
////		self.present(arController, animated: false) {
////			self.tabBarController?.selectedIndex = 0
////		}
//		self.tabBarController?.tabBar.isHidden = true
//	}
//	
//	override func viewWillDisappear(_ animated: Bool) {
//		self.tabBarController?.tabBar.isHidden = false
//	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.addChildViewController(arController)
		self.view.insertSubview(arController.view, at: 0)
		if let tabBarController = self.tabBarController as? TRTabBarController {
			tabBarController.selectTabAtIndex(index: 1)
		}
		
		if let place = singlePlace {
			self.arController.setAnnotations([place])
		} else if (places.count == 0) {
			locationManager.startUpdatingLocation()
		}
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		arController.view.removeFromSuperview()
		arController.removeFromParentViewController()
		
		singlePlace = nil
	}
	
	func showInfoView(forPlace place: Place) {
		let alert = UIAlertController(title: place.placeName , message: place.infoText, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		
		arController.present(alert, animated: true, completion: nil)
	}
	
	// -----
	
	@IBAction func leftAction(_ sender: Any) {
		self.tabBarController?.selectedIndex = 0
	}
	
	@IBAction func rightAction(_ sender: Any) {
		self.tabBarController?.selectedIndex = 2
	}
	
	@IBAction func centerAction(_ sender: Any) {
		// Do something...
		let places = arController.getAnnotations()
		if let place = places[Int(arc4random_uniform(UInt32(places.count)))] as? Place {
			showInfoView(forPlace: place)
		}
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
								let types = placeDict.object(forKey: "types") as! [String]
								var type = ""
								for t in types {
									type += t + " "
								}
								let address = placeDict.object(forKey: "vicinity") as! String
								
								let location = CLLocation(latitude: latitude, longitude: longitude)
								if let place = Place(location: location, reference: reference, name: name, address: address, types: type) {
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
							DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: {
								print("Updating locations")
								self.loadedPOIs = false
								self.places = []
								self.locationManager.startUpdatingLocation()
							})
						}
					}
				}
			}
		}
	}
}

extension CameraViewController: ARDataSource {
	func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
		var annotationView = Bundle.main.loadNibNamed("AnnotationView", owner: nil, options: nil)?.first as! AnnotationView
		annotationView.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
		if (singlePlace != nil) {
			annotationView = Bundle.main.loadNibNamed("AnnotationLView", owner: nil, options: nil)?.first as! AnnotationView
			annotationView.bigImage = true
			annotationView.frame = CGRect(x: 0, y: 0, width: 200, height: 240)
		}
		annotationView.annotation = viewForAnnotation
		annotationView.delegate = self
		
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

