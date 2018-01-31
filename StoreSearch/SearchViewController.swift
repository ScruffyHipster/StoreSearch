//
//  ViewController.swift
//  StoreSearch
//
//  Created by Tom Murray on 31/01/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	
	//TableVire array
	
	var searchResults = [SearchResult]()

}

//MARK:- Search bar delegates
extension SearchViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		if searchBar.text! != "justin bieber" {
		for i in 0...2 {
			let searchResult = SearchResult()
			searchResult.name = String(format: "Fake result %d for", i)
			searchResult.artistName = searchBar.text!
			searchResults.append(searchResult)
		}
		tableView.reloadData()
	}
	
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
		}
	}
}

//MARK:- Table view delegates
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchResults.count == 0 {
			return 1
		} else {
			return searchResults.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "SearchResultCell"
		
		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
		if cell == nil {
			cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
		}
		if searchResults.count == 0 {
			cell.textLabel!.text = "(Nothing found)"
			cell.detailTextLabel!.text = ""
		} else {
			let searchResult = searchResults[indexPath.row]
			cell.textLabel!.text = searchResult.name
			cell.detailTextLabel!.text = searchResult.artistName
		}
		return cell
	}
}


