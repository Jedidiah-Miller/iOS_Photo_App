//
//  CameraButtonController.swift
//  logRegTest
//
//  Created by jed on 10/10/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit


class MainViewController: UIViewController {

    var swipeViewController: SwipeViewController!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak var navView: NavView!
    @IBOutlet weak var cameraButton: DesignableButton!

    public var cameraOpen: Bool = true
    public var front: Bool = false

    lazy var cameraVC: CameraVC! = {
        return CameraVC()
    }()

    lazy var selfViewController: SelfViewController! = {
        let selfVC = self.storyboard?.instantiateViewController(withIdentifier: "SelfViewController") as? SelfViewController
        selfVC?.primaryVC = true
        selfVC?.user = UserService.currUser
        return selfVC
    } ()

    lazy var messageViewController: MessageViewController! = {
        return self.storyboard?.instantiateViewController(withIdentifier: "MessageViewController") as? MessageViewController
    } ()

    lazy var connectVC: ConnectVC! = {
        return ConnectVC(collectionViewLayout: UICollectionViewLayout().self)
    } ()

    lazy var discoverViewController: DiscoverViewController! = {
        return self.storyboard?.instantiateViewController(withIdentifier: "DiscoverViewController") as? DiscoverViewController
    } ()

//    var mainViewController: MainViewController!


    override func viewDidLoad() {
        super.viewDidLoad()

        let SB = UIStoryboard(name: "Main", bundle: nil)
        swipeViewController = SB.instantiateViewController(withIdentifier: "SwipeViewController") as? SwipeViewController
        swipeViewController.delegate = self

    }

    func setup() {

        navView.setupView()
//        navView.cameraButton.addTarget(self, action: #selector(capture), for: .touchUpInside)

        self.addChild(swipeViewController)
        swipeViewController.view.frame = self.view.frame
        self.view.insertSubview(swipeViewController.view, belowSubview: navView)
        swipeViewController.didMove(toParent: self)

    }



}


extension MainViewController: SwipeViewControllerDelegate {

    var viewControllers: [UIViewController?] {
        return [
            selfViewController,
            messageViewController,
            cameraVC, // center
            connectVC,
            discoverViewController,
        ]
    }

    var initialViewController: UIViewController {
        return cameraVC
    }

    func scrollViewDidScroll() {
//        let min: CGFloat = 0 ,
//            max: CGFloat = swipeViewController.viewSize.width,
//            x = swipeViewController.swipeView.contentOffset.x,
//            result = ((x - min) / (max - min)) - 1
//
//        navView.animate(to: result)
    }

}
