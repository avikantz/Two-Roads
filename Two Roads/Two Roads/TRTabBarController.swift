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

    override func viewDidLoad() {
        super.viewDidLoad()

		setSwipeAnimation(type: SwipeAnimationType.sideBySide)
		
        // Do any additional setup after loading the view.
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
