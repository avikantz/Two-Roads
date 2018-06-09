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
