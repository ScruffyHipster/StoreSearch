//
//  search.swift
//  StoreSearch
//
//  Created by Tom Murray on 22/02/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import Foundation
import UIKit

typealias SearchComplete = (Bool) -> Void

class Search {
	
	private var dataTask: URLSessionDataTask? = nil
	
	//enumerations
	enum State {
		case notSearchedYet
		case isLoading
		case noResults
		case results([SearchResult])
	}
	
	enum Category: Int {
		case all = 0
		case music = 1
		case software = 2
		case ebooks = 3
	
	var type: String {
		switch self {
		case .all: return ""
		case .music: return "musicTrack"
		case .software: return "software"
		case .ebooks: return "ebook"
			}
		}
	}
	
	private(set) var state: State = .notSearchedYet
	
	func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
		if  !text.isEmpty {
			dataTask?.cancel()
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			state = .isLoading
			
			let url = iTunesURL(searchText: text, category: category)
			
			let session = URLSession.shared
			dataTask = session.dataTask(with: url, completionHandler: {
				data, response, error in
				var newState = State.notSearchedYet
				//was the search cancelled
				var success = false
				if let error = error as NSError?, error.code == -999 {
					return
				}
				if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
				var searchResults = self.parse(data: data)
					if searchResults.isEmpty {
						newState = .noResults
					} else {
						searchResults.sort(by: <)
						newState = .results(searchResults)
					}
					success = true
				}
				DispatchQueue.main.async {
					self.state = newState
					completion(success)
					UIApplication.shared.isNetworkActivityIndicatorVisible = false
				}
			})
			dataTask?.resume()
		}
	}
	
	func iTunesURL(searchText: String, category: Category) -> URL {
		let locale = Locale.autoupdatingCurrent
		let language = locale.identifier
		let countryCode = locale.regionCode ?? "en_US"
		let kind = category.type
		let encodedText = searchText.addingPercentEncoding(withAllowedCharacters:  CharacterSet.urlQueryAllowed)!
		let urlString = "https://itunes.apple.com/search?" + "term=\(encodedText)&limit=200&entity=\(kind)" + "&lang=\(language)&country=\(countryCode)"
		let url = URL(string: urlString)
		print("Url: \(url!)")
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
	
}
