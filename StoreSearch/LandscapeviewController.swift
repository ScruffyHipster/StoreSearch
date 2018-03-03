//
//  LandscapeviewController.swift
//  StoreSearch
//
//  Created by Tom Murray on 15/02/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

class LandscapeviewController: UIViewController {
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var pageControl: UIPageControl!
	
	@IBAction func pageChanged(_ sender: UIPageControl) {
		UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: { self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
		}, completion: nil)
	}
	
	var search: Search!
	
	private var firstTime = true
	private var downloads = [URLSessionDownloadTask]()

    override func viewDidLoad() {
        super.viewDidLoad()
		//removes constraints from the view
        view.removeConstraints(view.constraints)
		view.translatesAutoresizingMaskIntoConstraints = true
		//remove constraints for page control
		pageControl.removeConstraints(pageControl.constraints)
		pageControl.translatesAutoresizingMaskIntoConstraints = true
		//remove constraints for scroll view
		scrollView.removeConstraints(scrollView.constraints)
		scrollView.translatesAutoresizingMaskIntoConstraints = true
		
		//adds background to the scroll view
		scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
		
		pageControl.numberOfPages = 0
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		scrollView.frame = view.bounds
		
		pageControl.frame = CGRect(x: 0, y: view.frame.size.height - pageControl.frame.size.height, width: view.frame.width, height: pageControl.frame.size.height)
		
		if firstTime {
		firstTime = false
		
			switch search.state {
			case .notSearchedYet:
				break
			case .isLoading:
				showSpinner()
				break
			case .noResults:
				showNothingFoundLabel()
				break
			case .results(let list):
				tileButtons(list)
			}
		}
	}
	
	deinit {
		print("deinit \(self)")
		for tasks in downloads {
			tasks.cancel()
		}
	}
	
	//MARK:- Private Methods
	
	@objc func buttonPressed(_ sender: UIButton) {
		performSegue(withIdentifier: "ShowDetail", sender: sender)
	}
	
	private func tileButtons(_ searchResults: [SearchResult]) {
		var columnsPerPage = 5
		var rowsPerPage = 3
		var itemWidth: CGFloat = 96
		var itemHeight: CGFloat = 88
		var marginX: CGFloat = 0
		var marginY: CGFloat = 20
		
		let viewWidth = scrollView.bounds.size.width
		
		//switch -- continue from here!!
		switch viewWidth {
		case 568:
			columnsPerPage = 6
			itemWidth = 94
			marginX = 2
			
		case 667:
			columnsPerPage = 7
			itemWidth = 95
			itemHeight = 98
			marginX = 1
			marginY = 29
			
		case 736:
			columnsPerPage = 8
			rowsPerPage = 4
			itemWidth = 92
			
		default:
			break
		}
		
		//Button size
		let buttonWidth: CGFloat = 82
		let buttonHeight: CGFloat = 82
		let paddingHorz = (itemWidth - buttonWidth)/2
		let paddingVert = (itemHeight - buttonHeight)/2
	
		// adds buttons
		var row = 0
		var column = 0
		var x = marginX
		for (index, result) in searchResults.enumerated() {
			//1
			let button = UIButton(type: .custom)
			button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
			downloadImage(for: result, andPlaceOn: button)
			button.tag = 2000 + index
			button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
			//2
			button.frame = CGRect(x: x + paddingHorz, y:marginY + CGFloat(row)*itemHeight + paddingVert, width: buttonWidth, height: buttonHeight)
			//3
			scrollView.addSubview(button)
			//4
			row += 1
			if row == rowsPerPage {
				row = 0; x += itemWidth; column += 1
				
				if column == columnsPerPage {
					column = 0; x += marginX * 2
				}
			}
		}
		let buttonsPerPage = columnsPerPage * rowsPerPage
		let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
		scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth, height: scrollView.bounds.size.height)
		
		print("Number of pages :\(numPages)")
		pageControl.numberOfPages = numPages
		pageControl.currentPage = 0
		
	}
	
	//MARK:- Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowDetail" {
			if case .results(let list) = search.state {
				let detailViewController = segue.destination as! DetailViewController
				let searchResult = list[(sender as! UIButton).tag - 2000]
				detailViewController.searchResult = searchResult
			}
		}
	}
	
	
	private func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
		if let url = URL(string: searchResult.imageSmall) {
			let task = URLSession.shared.downloadTask(with: url) {
				[weak button] url, response, error in
				if error == nil, let url = url,
					let data = try? Data(contentsOf: url),
					let image = UIImage(data: data) {
					DispatchQueue.main.async {
						if let button = button {
							button.setBackgroundImage(image.resized(withBounds: CGSize(width: button.bounds.width, height: button.bounds.height)), for: .normal)
						}
					}
				}
			}
			task.resume()
			downloads.append(task)
		}
	}
	

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LandscapeviewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let width = scrollView.bounds.size.width
		let page = Int((scrollView.contentOffset.x + width / 2) / width)
		pageControl.currentPage = page
	}
}

extension LandscapeviewController {
	private func showSpinner() {
		let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
		spinner.center = CGPoint(x: scrollView.bounds.midX + 0.5, y: scrollView.bounds.midY + 0.5)
		spinner.tag = 1000
		view.addSubview(spinner)
		spinner.startAnimating()
	}
}

//MARK:- searchResultsRecieved func
extension LandscapeviewController {
	func searchResultsReceived() {
		hideSpinner()
		
		switch search.state {
		case .notSearchedYet, .isLoading:
			break
		case .noResults:
			showNothingFoundLabel()
		case .results(let list):
			tileButtons(list)
		}
	}
	
	func hideSpinner() {
		view.viewWithTag(1000)?.removeFromSuperview()
	}
	
}

//MARK:- Nothing found label func
extension LandscapeviewController {
	private func showNothingFoundLabel() {
		let label = UILabel(frame: CGRect.zero)
		label.text = NSLocalizedString("Nothing Found", comment: "Text label for when nothing is found")
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.clear
		
		label.sizeToFit()
		
		var rect = label.frame
		rect.size.width = ceil(rect.size.width/2) * 2
		rect.size.height = ceil(rect.size.height/2) * 2
		label.frame = rect
		label.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
		view.addSubview(label)
	}
}
