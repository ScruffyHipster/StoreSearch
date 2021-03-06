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
	
	var downloadTask: URLSessionDownloadTask?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		let selectedView = UIView(frame: CGRect.zero)
		selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue:160/255, alpha: 0.5)
		selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	//public methods
	
	func configure(for result: SearchResult) {
		nameLabel.text = result.name
		
		if result.artistName.isEmpty {
			artistNameLabel.text = NSLocalizedString("Unknown", comment: "Shows unknown artist label if no data is thre for name in the search array")
		} else {
			artistNameLabel.text = String(format: NSLocalizedString("ARTIST_NAME_LABEL_FORMAT", comment: "format for the artist name"), result.artistName, result.type)
		}
		artworkImageView.image = UIImage(named: "Placeholder")
		if let smallURL = URL(string: result.imageSmall) {
			downloadTask = artworkImageView.loadImage(url: smallURL)
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		downloadTask?.cancel()
		downloadTask = nil
	}

}
