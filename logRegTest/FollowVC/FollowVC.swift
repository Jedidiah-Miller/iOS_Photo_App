//
//  FollowVC.swift
//  logRegTest
//
//  Created by jed on 11/26/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit

enum FollowVCState: String {
    case followers
    case following
    case select
    case search
}

class FollowVC: UICollectionViewController {

    var users: [User]? = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    var selectedUsers: [User]? {
        didSet {
            setContinueButtonState()
        }
    }

    var usersArrCopy: [User]!

    var state: FollowVCState = .following

    var shouldFilter: Bool = false

    var selectedIndexPath: IndexPath!

    let banner: Gradient = {
        let view = Gradient()
        view.layer.backgroundColor = UIColor.clear.cgColor
        view.backgroundColor = .clear
        view.startPoint = CGPoint(x: 0, y: 0)
        view.endPoint = CGPoint(x: 0, y: 1)
        view.FirstColor = #colorLiteral(red: 0.9981201291, green: 0.6054960489, blue: 0.1776913404, alpha: 0.67)
        view.SecondColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        return view
    }()

    lazy var searchBox: UITextField = {
        let view = UITextField()
        view.textColor = .black
        view.textAlignment = .left
        view.placeholder = "Search"
        view.tintColor = .black
        view.autocapitalizationType = .none
        view.autocorrectionType = .no
        view.clearButtonMode = .always
        view.setIcon(#imageLiteral(resourceName: "magnifyingGlass"), leftSide: true)
        view.backgroundColor = .clear
        view.layer.cornerRadius = 6
        view.returnKeyType = .done
        view.delegate = self
        return view
    }()

    lazy var searchBoxWidthConstraint: NSLayoutConstraint = {
        return searchBox.widthAnchor.constraint(equalToConstant: view.frame.width*0.7)
    }()

    lazy var bannerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "HiraMaruProN-W4", size: 16)
        label.text = "Follow"
        label.textAlignment = .center
        label.layer.shadowOpacity = 1
        label.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.layer.shadowRadius = 0.6
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        return label
    }()

    let dismissButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeTap), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "closeIcon"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .clear
        return button
    }()

    lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle("done", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1, green: 0.5968740582, blue: 0.03151972219, alpha: 1), for: .normal)
        button.setTitle("done", for: .disabled)
        button.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .disabled)
        button.addTarget(self, action: #selector(doneButtonTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var bannerBottomConstraint: NSLayoutConstraint!
    var bannerHeight: CGFloat!
    var YZero: CGFloat!

    var cellHeights: [IndexPath: CGFloat] = [:]
    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        return layout
    }()


    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        collectionView.collectionViewLayout = self.layout
        collectionView.alwaysBounceVertical = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(banner)

        [dismissButton,bannerLabel,searchBox].forEach {
            banner.addSubview($0)
        }

        setupConstraints()

        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.contentInset.top = bannerHeight
        collectionView.contentInset.bottom = bannerHeight
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FollowCell.self, forCellWithReuseIdentifier: FollowCell.ID)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        bannerLabel.text = state.rawValue

        switch self.state {

        case .followers: getFollowers()

        case .following: getFollowing()

        case .select:
            additionalSetup()
            selectedUsers = []
            getFollowing()

        case .search:
            getAllUsersVeryIneficiently()
            searchBox.becomeFirstResponder()

        }

    }


    func setupFromSelf() { }


    func additionalSetup() {
        banner.addSubview(doneButton)
        doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        doneButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    }


    func getAllUsersVeryIneficiently() {
        UserService.search(nil) { (users) in
            if let users = users {
                self.usersArrCopy = _Sort.sortUsersAlphabetically(users)
            }
        }
    }



    func getFollowers() {

        guard let followers = UserService.followers else { return }

        users = []

        followers.forEach {
            UserService.findOrObserve($0, completion: { (user) in
                self.users?.append(user)
            })
        }

    }

    func getFollowing() {

        guard let following = UserService.following else { return }

        users = []

        following.forEach {
            UserService.findOrObserve($0, completion: { (user) in
                self.users?.append(user)
            })
        }

    }


    @objc func closeTap() {
        self.dismiss(animated: true)
    }

    func setContinueButtonState() {

        doneButton.isEnabled = selectedUsers?.count ?? 0 > 0

    }

    @objc func doneButtonTap() {

        guard selectedUsers?.count ?? 0 > 0 else { return }

        var users = selectedUsers!
            users.append(UserService.currUser)

        ConvoService.checkIfExists(users: users.map { $0.uid } ) { convo in

            VCService.presentConvoVC(users: users, fromVC: self, convo: convo)

        }

        // MARK! - if the convo does exist then pass it back to the messagesVC and open it

        // also find a way to dismiss this VC once the convo VC has been presented and a message has been sent




    }



    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension FollowVC { // banner adjustment


    func setupConstraints() {

        [banner,bannerLabel,dismissButton,searchBox].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        bannerHeight = 40
        bannerBottomConstraint = banner.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bannerHeight - view.frame.height)

        bannerLabel.adjustsFontSizeToFitWidth = true
        bannerLabel.adjustsFontForContentSizeCategory = true

        let safeArea = view.safeAreaLayoutGuide
        let constraints: [NSLayoutConstraint] = [

            bannerBottomConstraint,
            banner.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            // banner.heightAnchor.constraint(greaterThanOrEqualToConstant: bannerHeight), // FIX
            banner.widthAnchor.constraint(equalToConstant: view.frame.width),

            dismissButton.topAnchor.constraint(equalTo: safeArea.topAnchor),
            dismissButton.widthAnchor.constraint(equalToConstant: 26),
            dismissButton.heightAnchor.constraint(equalToConstant: 26),
            dismissButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),

            bannerLabel.topAnchor.constraint(equalTo: dismissButton.topAnchor),
            bannerLabel.leadingAnchor.constraint(equalTo: dismissButton.leadingAnchor, constant: 40),

            searchBoxWidthConstraint,
            searchBox.heightAnchor.constraint(equalToConstant: 25),
            searchBox.bottomAnchor.constraint(equalTo: banner.bottomAnchor),
            searchBox.leadingAnchor.constraint(equalTo: dismissButton.leadingAnchor, constant: 40)

        ]

        NSLayoutConstraint.activate(constraints)

    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        adjustHeight()
    }


    func adjustHeight() {
        if YZero == nil {
            YZero = collectionView.contentOffset.y
        }
        let diffY = (YZero - collectionView.contentOffset.y) // how much scroll view has changed
        let bottomConstraint = (bannerHeight - view.frame.height) + diffY
        guard bottomConstraint >= 2*bannerHeight - view.frame.height else {
            if bannerBottomConstraint.constant != 2*bannerHeight - view.frame.height {
                bannerBottomConstraint.constant = 2*bannerHeight - view.frame.height
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            return
        }
        bannerBottomConstraint.constant = bottomConstraint
    }
}


extension FollowVC: UICollectionViewDelegateFlowLayout {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowCell.ID, for: indexPath) as! FollowCell

        cell.user = users?[indexPath.row]
        cell.setupData()

        switch state {

        case .followers:  print("nothing rn")

        case .following, .search: cell.checkIfFollows()

        case .select:
            cell.checkIfFollows()
            cell.additionalSetup()

            if selectedUsers?.contains(where: { $0.uid == cell.user.uid } ) ?? false {
                selectCell(cell, duration: 0, removed: false)
                print("RESELECTED A CELL !!!!!!")
            }

        }

        return cell
    }


    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? FollowCell else { return }

        selectedIndexPath = indexPath

        switch state {

        case .followers, .following, .search:

            let image: UIImageView? = cell.profileImageView

            let frame = cell.convert(cell.profileImageView.frame, to: nil)

            VCService.presentSelfVC(user: cell.user, fromVC: self, with: image, transitionFrame: frame)

        case .select:

            var removed = false

            if let index = selectedUsers!.firstIndex(where: {$0.uid == cell.user.uid} ) {
                selectedUsers!.remove(at: index)
                removed = true
            } else {
                self.selectedUsers?.append(cell.user)
            }

            selectCell(cell, duration: 0.3, removed: removed)

        }

    }


    func selectCell(_ cell: UICollectionViewCell, duration: Double, removed: Bool) {
        guard let cell = cell as? FollowCell else { return }
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
            cell.checkBox.FirstColor = removed ? #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) : #colorLiteral(red: 1, green: 0.2716672421, blue: 0.08280210942, alpha: 1)
            cell.checkBox.SecondColor = removed ? #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) : #colorLiteral(red: 1, green: 0.5968740582, blue: 0.03151972219, alpha: 1)
            cell.checkBox.transform = removed ? .identity : CGAffineTransform(scaleX: 1.4, y: 1.4)
        })
        cell.isSelected = !cell.isSelected
    }





// SIZE
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        return cellHeights[indexPath] = cell.frame.size.height
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        // selected users heights should be smaller and some other stuff idk

        return CGSize(width: view.frame.width, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }


}



extension FollowVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }


    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if !shouldFilter {
            state != .search ? usersArrCopy = users : nil
            shouldFilter = true
        }
        return true
    }


    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        resetCollectionView()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let newText = (searchBox.text! as NSString).replacingCharacters(in: range, with: string.lowercased())

        guard newText.count < 23 else { return false }

        newText == "" ? resetCollectionView() : filter(with: newText)

        return newText.count < 23

    }


    @objc func resetCollectionView() {

        guard shouldFilter else { return }
        searchBox.text = ""

        if state == .search {
            users = []
        } else {
            users = usersArrCopy
        }

    }

    func filter(with text: String) {
        users = usersArrCopy?.filter({
            $0.userName.lowercased().contains(text) // if the given string matches the usename at all
            // $0.userName.lowercased().starts(with: text) // if the username starts with the given string
        })
    }



}


extension UITextField {

    func setIcon(_ image: UIImage, leftSide: Bool) {
        let iconView = UIImageView(frame:
            CGRect(x: 10, y: 5, width: 20, height: 20))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
            CGRect(x: 20, y: 0, width: 30, height: 30))
        iconContainerView.addSubview(iconView)

        switch leftSide {

        case true:
            leftView = iconContainerView
            leftViewMode = .always


        case false:
            rightView = iconContainerView
            rightViewMode = .always

        }

    }
}

