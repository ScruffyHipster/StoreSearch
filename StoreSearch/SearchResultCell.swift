//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Tom Murray on 02/02/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var artistNameLabel: UILabel!
	@IBOutlet weak var artworkImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
