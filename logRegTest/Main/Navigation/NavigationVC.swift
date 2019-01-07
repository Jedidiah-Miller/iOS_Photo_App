//
//  NavigationVC.swift
//  logRegTest
//
//  Created by jed on 11/16/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit


class NavigationVC: UINavigationController, UINavigationControllerDelegate, UINavigationBarDelegate {

    var zoomTransitionDelegate: UINavigationControllerDelegate = ZoomTransitionDelegate()


    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = zoomTransitionDelegate

    }




}
