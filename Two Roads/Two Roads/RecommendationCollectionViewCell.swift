//
//  RecommendationCollectionViewCell.swift
//  Two Roads
//
//  Created by Avikant Saini on 6/10/18.
//  Copyright © 2018 tomato. All rights reserved.
//

import UIKit

class RecommendationCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var imageView: UIImageView!
	
	@IBOutlet weak var titleLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
