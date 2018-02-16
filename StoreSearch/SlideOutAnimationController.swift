//
//  SlideOutAnimationController.swift
//  StoreSearch
//
//  Created by Tom Murray on 15/02/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import Foundation
import UIKit

class SlideOutanimationController: NSObject, UIViewControllerAnimatedTransitioning {
	
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
			let containerView = transitionContext.containerView
			let time = transitionDuration(using: transitionContext)
			UIView.animate(withDuration: time, animations: {
				fromView.center.y -= containerView.bounds.size.height
				fromView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
			}, completion: { finished in transitionContext.completeTransition(finished)
			})
		}
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.3
	}
}
