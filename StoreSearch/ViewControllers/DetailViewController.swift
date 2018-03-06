//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Tom Murray on 12/02/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
	
	//Outlets
	
	@IBOutlet weak var popupView: UIView!
	@IBOutlet weak var artworkImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var artistNameLabel: UILabel!
	@IBOutlet weak var kindLabel: UILabel!
	@IBOutlet weak var genreLabel: UILabel!
	@IBOutlet weak var priceButton: UIButton!
	
	
	var searchResult: SearchResult! {
		didSet {
			if isViewLoaded {
				updateUI()
			}
		}
	}
	var downloadTask: URLSessionDownloadTask?
	var dismissStyle = AnimationStyle.fade
	var isPopUp = false
	
	enum AnimationStyle {
		case slide
		case fade
	}
	
	deinit {
		print("deinit \(self)")
		downloadTask?.cancel()
	}
	
	

    override func viewDidLoad() {
        super.viewDidLoad()
		view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
		popupView.layer.cornerRadius = 10
		if isPopUp {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
				gestureRecognizer.cancelsTouchesInView = false
				gestureRecognizer.delegate = self
				view.addGestureRecognizer(gestureRecognizer)
				view.backgroundColor = UIColor.clear
		} else {
			view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
			popupView.isHidden = true
		}
		if searchResult != nil {
			updateUI()
		}
		if let displayName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
			title = displayName
		}
	 // Do any additional setup after loading the view.
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		modalPresentationStyle = .custom
		transitioningDelegate = self
	}
	
	//Mark:- Actions
	@IBAction func close() {
		dismissStyle = .slide
		dismiss(animated: true, completion: nil)
		print("called")
	}
	
	@IBAction func openInStore() {
		if let url = URL(string: searchResult.storeURL) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}
	
	func updateUI() {
		
		nameLabel.text = searchResult.name
		
		if searchResult.artistName.isEmpty {
			artistNameLabel.text = NSLocalizedString("Unknown", comment: "Unknown label for artist label if no name has been found")
		} else {
			artistNameLabel.text = searchResult.artistName
		}
		genreLabel.text = searchResult.genre
		kindLabel.text = searchResult.kind
		
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = searchResult.currency
		
		let priceText: String
		if searchResult.price == 0 {
			priceText = NSLocalizedString("Free", comment: "Pricing label which will display free if no price found")
		} else if let text = formatter.string(from: searchResult.price as NSNumber) {
			priceText = text
		} else {
			priceText = ""
		}
		
		priceButton.setTitle(priceText, for: .normal)
		
		//get image
		if let largeURL = URL(string: searchResult.imageLarge) {
			downloadTask = artworkImageView.loadImage(url: largeURL)
		}
		
		UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
			self.popupView.isHidden = true
			}, completion: { _ in
				self.popupView.isHidden = false
			})
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

extension DetailViewController: UIViewControllerTransitioningDelegate {
	
	func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
	}
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return BounceAnimationController()
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		switch dismissStyle {
		case .slide:
			return SlideOutanimationController()
		case .fade:
			return FadeOutAnimationController()
		}
	}
}

extension DetailViewController {
	
}

extension DetailViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		return (touch.view === self.view)
	}
}

