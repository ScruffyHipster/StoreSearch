////
////  tempStoreForSearchFunc.swift
////  StoreSearch
////
////  Created by Tom Murray on 22/02/2018.
////  Copyright © 2018 Tom Murray. All rights reserved.
////
//
//import Foundation
//
//
//func performSearch() {
//	if !searchBar.text!.isEmpty {
//		searchBar.resignFirstResponder()
//		
//		dataTask?.cancel()
//		
//		isLoading = true
//		tableView.reloadData()
//		hasSearched = true
//		searchResults = []
//		
//		let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
//		let session = URLSession.shared
//		dataTask = session.dataTask(with: url) {//completion handler:
//			data, response, error in
//			if let error = error as NSError?, error.code == -999 {
//				return
//			} else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//				if let data = data {
//					self.searchResults = self.parse(data: data)
//					self.searchResults.sort(by: <)
//					DispatchQueue.main.async {
//						self.isLoading = false
//						self.tableView.reloadData()
//					}
//					return
//				}
//			} else {
//				print("Failure! \(response)")
//			}
//			
//			
//			
//			DispatchQueue.main.async {
//				self.isLoading = false
//				self.hasSearched = false
//				self.tableView.reloadData()
//				self.showNetworkError()
//			}
//		}
//		dataTask?.resume()
//	}
//}

