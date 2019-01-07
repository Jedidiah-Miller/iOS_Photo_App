//
//  NavigationTransitionDelegate.swift
//  logRegTest
//
//  Created by jed on 11/17/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit


protocol NavigationTransitionDelegate: class {
    func transitionWillStart(with transitionAnimator: TransitionAnimator)
    func transitionWillEnd(with transitionAnimator: TransitionAnimator)
    func referenceView(for transitionAnimator: TransitionAnimator) -> UIView?
    func referenceViewFrameInTransitioningView(for transitionAnimator: TransitionAnimator) -> CGRect?
}


class TransitionAnimator: NSObject {

    var transitionDuration: Double = 0.4
    weak var fromDelegate: NavigationTransitionDelegate?
    weak var toDelegate: NavigationTransitionDelegate?

    var transitionView: UIView?
    var isPresenting: Bool = true

    fileprivate func animatePresentTranstion(using transitionContext: UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView

        guard let toVC = transitionContext.viewController(forKey: .to),
            let toReferenceView = self.toDelegate?.referenceView(for: self),
            let fromVC = transitionContext.viewController(forKey: .from),
            let fromReferenceView = self.fromDelegate?.referenceView(for: self),
            let fromReferenceViewFrame = self.fromDelegate?.referenceViewFrameInTransitioningView(for: self)
            else {
                return
        }

        self.fromDelegate?.transitionWillStart(with: self)
        self.toDelegate?.transitionWillEnd(with: self)

        toVC.view.alpha = 0

        toReferenceView.isHidden = true
        containerView.addSubview(toVC.view)

        let referenceView = fromReferenceView

    }

}
