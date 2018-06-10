//
//  RecommendationsViewController.swift
//  Two Roads
//
//  Created by Avikant Saini on 6/9/18.
//  Copyright © 2018 tomato. All rights reserved.
//

import UIKit
import CoreLocation

let baseURL = "http://37781dcf.ngrok.io/"

let bgImages = ["cafe", "night_club", "pub", "park", "restaurant", "mall", "shopping_mall", "establishment", "outdoors"]

class RecommendationsViewController: UIViewController {
	
	fileprivate var places = [Place]()
	fileprivate let locationManager = CLLocationManager()
	fileprivate var currentLocation = CLLocation(latitude: 12, longitude: 77)
	fileprivate var loadedPOIs: Bool = false
	
	fileprivate var categories = ["mall", "park", "restaurant"] // Default
	
	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var collectionView: UICollectionView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		
		tableView.register(UINib.init(nibName: "RecommendationsTableViewCell", bundle: nil), forCellReuseIdentifier: "recommendationsCell")
		tableView.contentInset.bottom = 49
		
		collectionView.register(UINib(nibName: "RecommendationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "headlineCell")
		collectionView.register(UINib(nibName: "CollectionHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView")
		
		if (places.count == 0) {
			locationManager.startUpdatingLocation()
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
			URLSession.shared.dataTask(with: URL(string: baseURL + "recommend")!) { (data, response, error) in
				do {
					if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject] {
						self.categories = json["data"] as! [String]
						DispatchQueue.main.async {
							self.collectionView.reloadData()
						}
					}
				} catch _ {
					
				}
			}.resume()
		}
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let tabBarController = self.tabBarController as? TRTabBarController {
			tabBarController.selectTabAtIndex(index: 0)
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

extension RecommendationsViewController: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return places.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "recommendationsCell", for: indexPath) as! RecommendationsTableViewCell
		let place = places[indexPath.row]
		cell.titleLabel.text = place.placeName
		cell.categoryLabel.text = place.infoText
		cell.distanceLabel.text = String(format: "%.0f m", currentLocation.distance(from: place.location))
		cell.tagsLabel.text = place.types
		for image in bgImages {
			if (place.types!.contains(image)) {
				cell.backgroundImageView.image = UIImage(named: image)
				break
			}
		}
		return cell
	}
	
}

extension RecommendationsViewController: UITableViewDelegate {
	
//	func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//		return false
//	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 144
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
		let place = places[indexPath.row]
		if let tabBarVC = self.tabBarController as? TRTabBarController {
			tabBarVC.setSinglePlace(place: place)
		}
	}
	
}

extension RecommendationsViewController: UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return categories.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headlineCell", for: indexPath) as! RecommendationCollectionViewCell
		let place = categories[indexPath.row]
		cell.titleLabel.text = place.capitalized
		cell.imageView.image = UIImage(named: place)
		return cell
	}
	
}

extension RecommendationsViewController: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print("Cell selected")
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		if kind == UICollectionElementKindSectionHeader {
			let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath)
			return headerView
		}
		return UICollectionReusableView()
	}
	
}

extension RecommendationsViewController: CLLocationManagerDelegate {
	
	func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
		return true
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		if locations.count > 0 {
			let location = locations.last!
			if location.horizontalAccuracy < 100 {
				currentLocation = location
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
								let address = placeDict.object(forKey: "vicinity") as? String ?? placeDict.object(forKey: "formatted_address") as? String ?? ""
								
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
								self.tableView.reloadData()
								self.collectionView.reloadData()
							}
						}
					}
				}
			}
		}
	}
}
