//
//  AnnotationView.swift
//  Two Roads
//
//  Created by Avikant Saini on 6/9/18.
//  Copyright © 2018 tomato. All rights reserved.
//

import UIKit
import HDAugmentedReality

protocol AnnotationViewDelegate {
	// Interactions on annotation views
	func didTouch(annotationView: AnnotationView)
}

class AnnotationView: ARAnnotationView {
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var infoLabel: UILabel!
	
	var delegate: AnnotationViewDelegate?
	
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		populateUI()
	}
	
	func populateUI() {
		if let annotation = annotation as? Place {
			titleLabel.text = annotation.placeName
			infoLabel.text = String(format: "%.0f m", annotation.distanceFromUser)
		}
	}

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		delegate?.didTouch(annotationView: self)
	}

}
