//
//  HomeViewController.swift
//  Two Roads
//
//  Created by Avikant Saini on 6/9/18.
//  Copyright © 2018 tomato. All rights reserved.
//

import UIKit
import HyperTrack

let testUserName = "lokeshChauhan"
let testUserId = "8095138333"

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
	}
	
	override func viewDidAppear(_ animated: Bool) {

		if let _ = HyperTrack.getUserId() {
			loginSuccess()
		} else {
			HyperTrack.getOrCreateUser(name: testUserName, phone: testUserId, uniqueId: testUserId) { (user, error) in
				if ((error) != nil) {
					print("Unable to login: ")
					print(error.debugDescription)
				} else {
					self.loginSuccess()
				}
			}
		}
    }

	func loginSuccess() {
		// Start tracking data
		
		print("Logged in successfully, tracking data...")
		if let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") {
			self.present(tabBarVC, animated: false) {
				print("Presenting tab bar...")
			}
		}
		
		activityIt()
	}
	
	func activityIt() {
		
		let actionId = UUID.init().uuidString
		
		HyperTrack.resumeTracking()
		let actionParams = HTActionParams()
			.setType(type: "visit")
			.setUniqueId(uniqueId: actionId)
		
		HyperTrack.createAction(actionParams) { action, error in
			if let error = error {
				// Handle createAction API error here
				print("Error in creating action")
				print(error.debugDescription)
				return
			}
			
			if let action = action {
				// Handle createAction API success here
				print("Action created successfully")
				print(action.description)
			}
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
			HyperTrack.completeActionInSync(actionId) { (action, error) in
				if let _ = error {
					// Handle completeActionInSynch API error here
					print("Action could not be completed")
					return;
				}
				
				if let _ = action {
					// Handle completeActionInSynch API success here
					print("Action seems to be completed")
				}
			}
			self.activityIt()
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
