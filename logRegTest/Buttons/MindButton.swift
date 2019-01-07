//
//  MindButton.swift
//  logRegTest
//
//  Created by jed on 12/5/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import UIKit

class MindButton: DesignableButton {


    let orange: UIView = {
        let view = UIView()
        view.layer.borderColor = #colorLiteral(red: 1, green: 0.274296999, blue: 0.0726166293, alpha: 1)
        return view
    }()

    let red: UIView = {
        let view = UIView()
        view.layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        return view
    }()

    let pink: UIView = {
        let view = UIView()
        view.layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0.9526286721, alpha: 1)
        return view
    }()

    let purple: UIView = {
        let view = UIView()
        view.layer.borderColor = #colorLiteral(red: 0.6201555729, green: 0, blue: 1, alpha: 1)
        return view
    }()

    let blue: UIView = {
        let view = UIView()
        view.layer.borderColor = #colorLiteral(red: 0, green: 0.07427657396, blue: 1, alpha: 1)
        return view
    }()

    let lightBlue: UIView = {
        let view = UIView()
        view.layer.borderColor = #colorLiteral(red: 0, green: 1, blue: 0.9371594191, alpha: 1)
        return view
    }()

    let green: UIView = {
        let view = UIView()
        view.layer.borderColor = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
        return view
    }()

    let yellow: UIView = {
        let view = UIView()
        view.layer.borderColor = #colorLiteral(red: 0.9861351848, green: 1, blue: 0, alpha: 1)
        return view
    }()


    open var shouldAnimate: Bool = true


    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }


    func setup() {

        [orange,red,pink,purple,blue,lightBlue,green,yellow].forEach { view in
            insertSubview(view, at: 0)
//            view.alpha = 0.7
            view.isUserInteractionEnabled = false
            view.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(view, at: 0)
        }

    }


    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        subviews.forEach { view in
            let constraints: [NSLayoutConstraint] = [
                view.topAnchor.constraint(equalTo: topAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor),
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
            ]

            NSLayoutConstraint.activate(constraints)

        }

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        subviews.forEach { view in
            view.layer.borderWidth = (layer.borderWidth*0.8)
            view.layer.cornerRadius = view.frame.height/2
        }

    }



    func animate() { // very bad no

        guard shouldAnimate else { return } // BS // the only way i could stop it

        // left half <-------------------

        UIView.animate(withDuration: 0.5, delay: 0, options:.curveLinear, animations: {
            self.orange.transform = CGAffineTransform(translationX: -1, y: 4)
        }) { (completion) in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                self.orange.transform = .identity
            })
        }

        UIView.animate(withDuration: 0.5, delay: 0.1, options:.curveLinear, animations: {
            self.red.transform = CGAffineTransform(translationX: -2, y: -3)
        }) { (completion) in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                self.red.transform = .identity
            })
        }

        UIView.animate(withDuration: 0.5, delay: 0.2, options:.curveLinear, animations: {
            self.pink.transform = CGAffineTransform(translationX: -3, y: 2)
        }) { (completion) in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                self.pink.transform = .identity
            })
        }

        UIView.animate(withDuration: 0.5, delay: 0.3, options:.curveLinear, animations: {
            self.purple.transform = CGAffineTransform(translationX: -4, y: -1)
        }) { (completion) in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                self.purple.transform = .identity
            })
        }

        // -------------------> right half

        UIView.animate(withDuration: 0.5, delay: 0.4, options:.curveLinear, animations: {
            self.blue.transform = CGAffineTransform(translationX: 4, y: 1)
        }) { (completion) in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                self.blue.transform = .identity
            })
        }

        UIView.animate(withDuration: 0.5, delay: 0.5, options:.curveLinear, animations: {
            self.lightBlue.transform = CGAffineTransform(translationX: 3, y: -2)
        }) { (completion) in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                self.lightBlue.transform = .identity
            })
        }

        UIView.animate(withDuration: 0.5, delay: 0.6, options:.curveLinear, animations: {
            self.green.transform = CGAffineTransform(translationX: 2, y: 3)
        }) { (completion) in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                self.green.transform = .identity
            })
        }

        UIView.animate(withDuration: 0.5, delay: 0.7, options:.curveLinear, animations: {
            self.yellow.transform = CGAffineTransform(translationX: 1, y: -4)
        }) { (completion) in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                self.yellow.transform = .identity
            }) { (completion) in
                self.animate()
            }
        }

    }



    func photoAnimation() {

        UIView.animate(withDuration: 0.125, delay: 0, options:.curveEaseInOut, animations: {

            self.orange.transform = CGAffineTransform(translationX: -1, y: 4)
            self.red.transform = CGAffineTransform(translationX: -2, y: -3)
            self.pink.transform = CGAffineTransform(translationX: -3, y: 2)
            self.purple.transform = CGAffineTransform(translationX: -4, y: -1)

            self.blue.transform = CGAffineTransform(translationX: 4, y: 1)
            self.lightBlue.transform = CGAffineTransform(translationX: 3, y: -2)
            self.green.transform = CGAffineTransform(translationX: 2, y: 3)
            self.yellow.transform = CGAffineTransform(translationX: 1, y: -4)

        })

    }




    func stopAnimation() {

        shouldAnimate = false

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.subviews.forEach { view in
                view.transform = .identity
                view.layer.removeAllAnimations()
            }
        })

    }



}
