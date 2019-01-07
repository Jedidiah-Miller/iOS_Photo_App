//
//  MessageViewController.swift
//  logRegTest
//
//  Created by jed on 10/30/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseFirestore


class MessageViewController: UIViewController {


    static var convos = [Convo]()
    @IBOutlet weak var newChatButton: DesignableButton!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatBanner: Gradient! {
        didSet {
            chatBanner.layer.backgroundColor = UIColor.clear.cgColor
            chatBanner.backgroundColor = .clear
            chatBanner.FirstColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
            chatBanner.SecondColor = .clear
        }
    }
    var chatBannerBottomConstraint: NSLayoutConstraint!,
        chatBannerheight: CGFloat!,
        scrollCenter: CGFloat!

    @IBOutlet weak var chatLabel: UILabel! {
        didSet {
            chatLabel.layer.shadowOpacity = 1
            chatLabel.layer.shadowRadius = 0.5
            chatLabel.layer.shadowOffset = .zero
            chatLabel.layer.shadowColor = UIColor.black.cgColor
        }
    }

    let cellNib: UINib = UINib(nibName: "ConvoTableViewCell", bundle: nil)
    let cellID: String = "ConvoCell"


    var listener: ListenerRegistration!

    func baseQuery() -> Query {

        return Firestore.firestore().collection("Convos")
    }

    var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
        }
    }

    deinit {
        listener.remove()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        setConstraints()

        tableView.contentInset.top = chatBannerheight/2
        tableView.contentInset.bottom = 88 // find the height of the nav bar

        self.query = baseQuery()

        tableView.register(cellNib, forCellReuseIdentifier: cellID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white

        MessageViewController.convos = []

        getConvos()

    }

    func setConstraints() {

        chatBanner.translatesAutoresizingMaskIntoConstraints = false
        chatBannerheight = 80
        chatBannerBottomConstraint = chatBanner.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: chatBannerheight - view.frame.height)
        let constraints: [NSLayoutConstraint] = [

            chatBannerBottomConstraint,
            chatBanner.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
//            chatBanner.heightAnchor.constraint(greaterThanOrEqualToConstant: chatBannerheight),
            chatBanner.widthAnchor.constraint(equalToConstant: view.frame.width)

        ]

        NSLayoutConstraint.activate(constraints)

    }





    @IBAction func newChatTapped(_ sender: Any) {
        VCService.presentFollowVC(fromVC: self, for: .select)
    }


    @IBAction func unwindToChatVC(_ unwindSegue: UIStoryboardSegue) { }



}

