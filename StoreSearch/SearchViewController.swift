//
//  ViewController.swift
//  StoreSearch
//
//  Created by Tom Murray on 31/01/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
	
	struct TableViewCellIdentifiers {
		static let searchResultCell = "SearchResultCell"
		static let nothingFoundCell = "NothingFoundCell"
		static let loadingCell = "LoadingCell"
	}
	
	@IBOutlet weak var segmentedControl: UISegmentedControl!

	@IBAction func segmentedChanged(_ sender: UISegmentedControl) {
		performSearch()
		print("Segment changed: \(sender.selectedSegmentIndex)")
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
		var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
		tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
		cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
		tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
		tableView.rowHeight = 80
		cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
		tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
		searchBar.becomeFirstResponder()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
		super.willTransition(to: newCollection, with: coordinator)
		switch newCollection.verticalSizeClass {
		case .compact: showLandscape(with: coordinator)
		case .regular, .unspecified: hideLandscape(with: coordinator)
		}
	}

	//Outlets\
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	
	//Instance Vars
	
	var landscapeVC: LandscapeviewController?
	var detailVC: DetailViewController?
	
	private let search = Search()
	
	//MARK:- Private Methods

	
	func showNetworkError() {
		let alert = UIAlertController(title: "Whoops ...", message: "There was an error accessing the iTunes store Please try again", preferredStyle: .alert)
	
		let action = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}
	
	//Landscape orientation
	func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
		guard landscapeVC == nil else {return}
		
		landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeviewController
		
		if let controller = landscapeVC {
			controller.search = search //left off here
			controller.view.frame = view.bounds
			controller.view.alpha = 0
			view.addSubview(controller.view)
			addChildViewController(controller)
				coordinator.animate(alongsideTransition: { _ in
				controller.view.alpha = 1
				self.searchBar.resignFirstResponder()
				self.closePop()
			}, completion: { _ in
				controller.didMove(toParentViewController: self)
			})
		}
	}
	
	func hideLandscape(with coordinatior: UIViewControllerTransitionCoordinator) {
		if let controller = landscapeVC {
			controller.willMove(toParentViewController: nil)
			coordinatior.animate(alongsideTransition: { _ in
				controller.view.alpha = 0
			}, completion: { _ in
				controller.removeFromParentViewController()
				self.landscapeVC = nil
			})
		}
	}
	
	func closePop() {
		if self.presentedViewController != nil {
			self.dismiss(animated: true, completion: nil)
		}
	}
}
//MARK:- Search bar delegates
extension SearchViewController: UISearchBarDelegate {
	
	func performSearch() {
		if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
			search.performSearch(for: searchBar.text!, category: category, completion: { success in
			if !success {
				self.showNetworkError()
			}
			self.tableView.reloadData()
		})
		tableView.reloadData()
		searchBar.resignFirstResponder()
		}
	}
	
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
		}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		performSearch()
	}
}


//MARK:- Table view delegates
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch search.state {
		case .notSearchedYet:
			return 0
		case .isLoading:
			return 1
		case .noResults:
			return 1
		case .results(let list):
			return list.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch search.state {
		case .notSearchedYet:
			fatalError("You should never get here")
		case .isLoading:
			let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
			let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
			spinner.startAnimating()
			return cell
		case .noResults:
			return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
		case .results(let list):
			let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
			let searchResult = list[indexPath.row]
			cell.configure(for: searchResult)
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		performSegue(withIdentifier: "ShowDetail", sender: indexPath)
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		switch search.state {
		case .notSearchedYet, .isLoading, .noResults:
			return nil
		case .results:
			return indexPath
		}
	}
}


extension SearchViewController {
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowDetail" {
			if case .results(let list) = search.state {
				let detailViewController = segue.destination as! DetailViewController
				let indexPath = sender as! IndexPath
				let searchResult = list[indexPath.row]
				detailViewController.searchResult = searchResult
			}
		}
	}
}


