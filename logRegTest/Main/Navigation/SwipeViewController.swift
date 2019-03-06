//
//  Buttons.swift
//  logRegTest
//
//  Created by jed on 10/8/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit


protocol SwipeViewControllerDelegate {
    var viewControllers: [UIViewController?] { get }
    var initialViewController: UIViewController { get }
    func scrollViewDidScroll()
}

enum TransitionDuration: Double {
    case normal = 0.8
    case quick = 0.2
}

class SwipeViewController: UIViewController {

    var swipeView: UIScrollView { return view as! UIScrollView }
    var viewSize: CGSize { return swipeView.frame.size }
    var viewControllers: [UIViewController?]!
    var delegate: SwipeViewControllerDelegate?

    static var transitionDuration: TransitionDuration = .normal

    static let userTransitionDuration: String = "userTransitionDuration"


    override func loadView() {

        let swipeView = UIScrollView()
            swipeView.backgroundColor = .clear
            swipeView.delegate = self
            swipeView.bounces = false
            swipeView.showsHorizontalScrollIndicator = false
            swipeView.showsVerticalScrollIndicator = false
            swipeView.isPagingEnabled = true
            swipeView.isScrollEnabled = false

        view = swipeView
        view.backgroundColor = .clear

    }


    override func viewDidLoad() {
        super.viewDidLoad()

        if let duration = UserDefaults.standard.value(forKey: SwipeViewController.userTransitionDuration) as? TransitionDuration.RawValue {
            SwipeViewController.transitionDuration = TransitionDuration(rawValue: duration)!
        }

    }

    override func viewDidAppear(_ animated: Bool) { // this is how each controllers view is embedded in
        super.viewDidAppear(animated)

        viewControllers = delegate?.viewControllers
        for (index, controller) in viewControllers.enumerated() {
            if let controller = controller {
                addChild(controller)
                controller.view.frame = frame(for: index)
                swipeView.addSubview(controller.view) // adds the view
                controller.didMove(toParent: self)
            }
        }
        swipeView.contentSize = CGSize(width: viewSize.width * CGFloat(viewControllers.count), height: viewSize.height )
        if let controller = delegate?.initialViewController {
            setController(to: controller, animated: false) // extension at bottom of file
        }

    }

}


fileprivate extension SwipeViewController {
    func frame(for index: Int) -> CGRect {
        return CGRect(x: CGFloat(index)*viewSize.width, y: 0, width: viewSize.width, height: viewSize.height)
    }
    func indexFor(controller: UIViewController?) -> Int? {
        return viewControllers.firstIndex(where: {$0 == controller} )
    }
}

extension SwipeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ swipeView: UIScrollView) {
        delegate?.scrollViewDidScroll()
    }
}

extension SwipeViewController { // offesets the page to the camera // should work for every size screen

    public func setController(to controller: UIViewController, animated: Bool) {

        guard let index = indexFor(controller: controller) else { return }
        let contentOffset = CGPoint(x: viewSize.width * CGFloat(index) , y: 0 )
        guard contentOffset != swipeView.contentOffset else { return }
        NavView.disabled = true
        let duration: Double = SwipeViewController.transitionDuration.rawValue

        if animated {

            switch SwipeViewController.transitionDuration {

            case .normal:

                UIView.animate(withDuration: duration/4, delay: 0, options: [.curveEaseInOut, .layoutSubviews], animations: {

                    self.swipeView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    self.swipeView.frame.origin.y = 0

                }) { (completion) in
                    UIView.animate(withDuration: duration/3, delay: 0, options: [.curveEaseInOut, .layoutSubviews], animations: {
                        self.swipeView.setContentOffset(contentOffset, animated: false)
                    }) { (completion) in
                        UIView.animate(withDuration: duration/4, delay: 0, options: [.curveEaseInOut, .layoutSubviews], animations: {

                            self.swipeView.transform = .identity
                            self.swipeView.frame.origin.y = 0

                        }) { (completion) in
                            NavView.disabled = false
                        }
                    }
                }

            case .quick:
                UIView.animate(withDuration: duration, delay: 0,options: [.curveEaseInOut,.allowUserInteraction,.layoutSubviews],animations: {
                                self.swipeView.setContentOffset(contentOffset, animated: false)
                }) { completion in
                    NavView.disabled = false
                }

            }


        } else {
            swipeView.setContentOffset(contentOffset, animated: animated)
            NavView.disabled = false
        }

        
    }


}

