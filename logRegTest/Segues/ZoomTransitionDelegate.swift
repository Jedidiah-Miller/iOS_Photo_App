//
//  ZoomTransitionDelegate.swift
//  logRegTest
//
//  Created by jed on 11/16/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit

@objc
protocol ZoomViewController {
    func zoomImageView(for transition: ZoomTransitionDelegate) -> UIImageView?
    func zoomMainView(for transition: ZoomTransitionDelegate) -> UIView?
}

public enum ZoomTransitionState {
    case initial
    case final
}

class ZoomTransitionDelegate: NSObject {

    var transitionDuration: Double = 0.4
    var operation: UINavigationController.Operation = .none
    private let zoomScale: CGFloat = 15
    private let backgroundScale:CGFloat = 0.7

    typealias ZoomViews = (otherView: UIView, imageView: UIView)

    func configureViews(for state: ZoomTransitionState, containerView: UIView, backgroundVC: UIViewController, viewsInBackground: ZoomViews, viewsInForeground: ZoomViews, snapshotViews: ZoomViews) {

        switch state {

        case .initial:
            backgroundVC.view.transform = CGAffineTransform.identity
            backgroundVC.view.alpha = 1
            snapshotViews.imageView.frame = containerView.convert(viewsInBackground.imageView.frame, from: viewsInBackground.imageView.superview)

        case .final:
            backgroundVC.view.transform = CGAffineTransform(scaleX: backgroundScale, y: backgroundScale)
            backgroundVC.view.alpha = 0
            snapshotViews.imageView.frame = containerView.convert(viewsInForeground.imageView.frame, from: viewsInForeground.imageView.superview)

        }
    }

}

extension ZoomTransitionDelegate: UIViewControllerAnimatedTransitioning {

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let duration = transitionDuration(using: transitionContext)
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        let containerView = transitionContext.containerView

        var backgroundVC = fromVC
        var foregroundVC = toVC
        var preTransitionState = ZoomTransitionState.initial
        var postTransitionState = ZoomTransitionState.final

        if operation == .pop {
            backgroundVC = toVC
            foregroundVC = fromVC
            preTransitionState = .final
            postTransitionState = .initial
        }

        let possibleBackgroundImageView = (backgroundVC as? ZoomViewController)?.zoomImageView(for: self)
        let possibleForegroundImageView = (foregroundVC as? ZoomViewController)?.zoomImageView(for: self)

        assert(possibleBackgroundImageView != nil, "cannot find image")
        assert(possibleForegroundImageView != nil, "cannot find image")

        let backgroundImageView = possibleBackgroundImageView!
        let foregroundImageView = possibleForegroundImageView!

        let imageViewSnapshot = UIImageView(image: backgroundImageView.image)
            imageViewSnapshot.contentMode = .scaleAspectFill // PROBABLY change these
            imageViewSnapshot.layer.masksToBounds = true // PROBABLY change these

        backgroundImageView.isHidden = true
        foregroundImageView.isHidden = true
        let foregroundViewColor = foregroundVC?.view.backgroundColor
        foregroundVC?.view.backgroundColor = .clear
        containerView.backgroundColor = .white

        containerView.addSubview(backgroundVC!.view)
        containerView.addSubview(foregroundVC!.view)
        containerView.addSubview(imageViewSnapshot)

        configureViews(for: preTransitionState, containerView: containerView, backgroundVC: backgroundVC!, viewsInBackground: (backgroundImageView, backgroundImageView),viewsInForeground: (foregroundImageView, foregroundImageView), snapshotViews: (imageViewSnapshot, imageViewSnapshot))

        foregroundVC!.view.layoutIfNeeded()

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            self.configureViews(for: postTransitionState, containerView: containerView, backgroundVC: backgroundVC!, viewsInBackground: (backgroundImageView, backgroundImageView),viewsInForeground: (foregroundImageView, foregroundImageView), snapshotViews: (imageViewSnapshot, imageViewSnapshot))
        }) { (completion) in
            backgroundVC?.view.transform = CGAffineTransform.identity
            imageViewSnapshot.removeFromSuperview()
            backgroundImageView.isHidden = false
            foregroundImageView.isHidden = false
            foregroundVC!.view.backgroundColor = foregroundViewColor
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }

}

extension ZoomTransitionDelegate: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if fromVC is ZoomViewController && toVC is ZoomViewController {
            self.operation = operation
            return self
        } else {
            return nil
        }

    }

}
