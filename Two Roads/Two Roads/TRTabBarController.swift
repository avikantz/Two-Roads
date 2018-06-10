//
//  TRTabBarController.swift
//  Two Roads
//
//  Created by Avikant Saini on 6/9/18.
//  Copyright © 2018 tomato. All rights reserved.
//

import UIKit
import SwipeableTabBarController

class TRTabBarController: SwipeableTabBarController {
	
	@IBOutlet var tabbarView: UIView!
	
	@IBOutlet weak var discoverButton: UIButton!
	@IBOutlet weak var arButton: UIButton!
	@IBOutlet weak var profileButton: UIButton!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		setSwipeAnimation(type: SwipeAnimationType.sideBySide)
		
		tabbarView.frame.size = CGSize(width: self.view.frame.width, height: 49)
		tabbarView.frame.origin = CGPoint(x: self.view.frame.origin.x, y: self.view.frame.height - 49)
		self.view.addSubview(tabbarView)
		
		
        // Do any additional setup after loading the view.
    }
	
	@IBAction func tabButtonTapped(_ sender: UIButton) {
//		for button in [discoverButton, arButton, profileButton] {
//			button?.alpha = 0.5
//		}
		self.selectedIndex = sender.tag
//		sender.alpha = 1
	}
	
	func selectTabAtIndex(index: Int) {
		let buttons = [discoverButton, arButton, profileButton]
		for i in 0...2 {
			buttons[i]?.alpha = index == i ? 1 : 0.5
		}
	}
	
	func setSinglePlace(place: Place) {
		if let cameraVC = self.viewControllers?[1] as? CameraViewController {
			cameraVC.singlePlace = place
		}
		self.selectedIndex = 1
	}
	
//	override func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//		let index = tabBarController.viewControllers?.firstIndex(of: viewController)
//		let buttons = [discoverButton, arButton, profileButton]
//		for i in 0...2 {
//			buttons[i]?.alpha = index == i ? 1 : 0.5
//		}
//		super.tabBarController(tabBarController, didSelect: viewController)
//	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
