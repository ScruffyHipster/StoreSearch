//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Tom Murray on 11/02/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
	func loadImage(url: URL) -> URLSessionDownloadTask {
		let session = URLSession.shared
		
		let downloadtask = session.downloadTask(with: url) {
			[weak self] url, response, error in
			if error == nil, let url = url, let data  = try? Data(contentsOf: url), let image = UIImage(data: data) {
				DispatchQueue.main.async {
					if let weakSelf = self {
						weakSelf.image = image
					}
				}
			}
		}
		downloadtask.resume()
		return downloadtask
	}
}
