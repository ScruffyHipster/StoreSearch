//
//  MenuViewController.swift
//  StoreSearch
//
//  Created by Tom Murray on 06/03/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit
import Foundation

protocol MenuViewControllerDelegate: class {
	func menuViewControllerSendEmail(_ controller: MenuViewController)
}

class MenuViewController: UITableViewController {

	weak var delegate: MenuViewControllerDelegate?
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		if indexPath.row == 0 {
			delegate?.menuViewControllerSendEmail(self)
		}
	}
	
}
