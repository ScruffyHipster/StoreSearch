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

	//Outlets\
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	
	//Instance Vars
	var dataTask: URLSessionDataTask?
	
	//TableView array
	
	var searchResults = [SearchResult]()
	var hasSearched = false
	var isLoading = false
	
	//AMRK:- Private Methods

	func iTunesURL(searchText: String, category: Int) -> URL {
		let kind: String
		switch category {
		case 1: kind = "musicTrack"
		case 2: kind = "software"
		case 3: kind = "ebook"
		default: kind = ""
		}
		
		let encodedText = searchText.addingPercentEncoding(withAllowedCharacters:  CharacterSet.urlQueryAllowed)!
		let urlString = "https://itunes.apple.com/search?term=\(encodedText)&limit=200&entity=\(kind)"
		let url = URL(string: urlString)
		return url!
	}
	
	
	
	func parse(data: Data) -> [SearchResult] {
		do {
			let decoder = JSONDecoder()
			let result = try decoder.decode(ResultArray.self, from: data)
			return result.results
		} catch {
			print("JSON Error: \(error)")
			return []
		}
	}
	
	func showNetworkError() {
		let alert = UIAlertController(title: "Whoops ...", message: "There was an error accessing the iTunes store Please try again", preferredStyle: .alert)
	
		let action = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}
}

//MARK:- Search bar delegates
extension SearchViewController: UISearchBarDelegate {
	
	func performSearch() {
		if !searchBar.text!.isEmpty {
			searchBar.resignFirstResponder()
			
			dataTask?.cancel()
			
			isLoading = true
			tableView.reloadData()
			hasSearched = true
			searchResults = []

			let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
			let session = URLSession.shared
			dataTask = session.dataTask(with: url) {//completion handler:
				data, response, error in
					if let error = error as NSError?, error.code == -999 {
						return
					} else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
						if let data = data {
							self.searchResults = self.parse(data: data)
							self.searchResults.sort(by: <)
							DispatchQueue.main.async {
								self.isLoading = false
								self.tableView.reloadData()
							}
							return
						}
					} else {
						print("Failure! \(response!)")
				}
				DispatchQueue.main.async {
					self.isLoading = false
					self.hasSearched = false
					self.tableView.reloadData()
					self.showNetworkError()
				}
				}
			dataTask?.resume()
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
		if isLoading {
			return 1
		} else if !hasSearched {
			return 0
	    } else if searchResults.count == 0 {
			return 1
		} else {
			return searchResults.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if isLoading {
			let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
			let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
			spinner.startAnimating()
			return cell
		} else if searchResults.count == 0 {
			return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
			let searchResult = searchResults[indexPath.row]
			cell.nameLabel!.text = searchResult.name
			if searchResult.artistName.isEmpty {
				cell.artistNameLabel.text = "Unknown"
			} else {
				cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, searchResult.type)
			}
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if searchResults.count == 0 || isLoading {
			return nil
		} else {
			return indexPath
		}
	}
}


