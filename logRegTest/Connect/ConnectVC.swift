//
//  ConnectVC.swift
//  logRegTest
//
//  Created by jed on 11/18/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit


class ConnectVC: UICollectionViewController {

    let banner: Gradient = {
        let view = Gradient()
        view.layer.backgroundColor = UIColor.clear.cgColor
        view.backgroundColor = .clear
        view.startPoint = CGPoint(x: 0, y: 0)
        view.endPoint = CGPoint(x: 0, y: 1)
        view.FirstColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
        view.SecondColor = .clear
        return view
    }()

    lazy var bannerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "HiraMaruProN-W4", size: 24)
        label.text = "Feed"
        label.textAlignment = .center
        label.layer.shadowOpacity = 1
        label.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.layer.shadowRadius = 0.8
        label.layer.shadowOffset = .zero
//        label.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.4883347603)
        label.clipsToBounds = false
        return label
    }()

    var bannerBottomConstraint: NSLayoutConstraint!
    var bannerHeight: CGFloat!
    var YZero: CGFloat!

    var memories = [Memory]()

    var fetchingMore: Bool = false
    var endReached = false
    var cellHeights: [IndexPath: CGFloat] = [:]

    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        return layout
    }()

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = .gray
        refreshControl.backgroundColor = .clear
        refreshControl.isUserInteractionEnabled = false
        return refreshControl
    }()


    var selectedIndexPath: IndexPath!

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        MemoryService.query = MemoryService.baseQuery() // idk
        getMemories()

    }


    func setup() {

        collectionView.collectionViewLayout = self.layout
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true

        collectionView.allowsSelection = true

        view.addSubview(banner)
        banner.addSubview(bannerLabel)
        collectionView.backgroundColor = .white
        setupConstraints()

        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.contentInset.top = bannerHeight
        collectionView.contentInset.bottom = bannerHeight*2
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.refreshControl = refreshControl
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: FeedCell.ID)

    }

    func getMemories() {

        MemoryService.getMemories(discover: false, memories: memories) { (updated) in

            if let newMemories = updated, !newMemories.isEmpty {

                self.memories = newMemories

                self.memories.sort { $0.createdAt > $1.createdAt }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }

            } else { // no memories

                // make a default cell


            }

        }
    }


    @objc func handleRefresh() {

        getMemories()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshControl.endRefreshing()
        }
    }


}

extension ConnectVC { // banner adjustment

    func setupConstraints() {

        [banner, bannerLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }

        bannerHeight = 40
        bannerBottomConstraint = banner.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bannerHeight - view.frame.height)

        bannerLabel.adjustsFontSizeToFitWidth = true
        bannerLabel.adjustsFontForContentSizeCategory = true



        let constraints: [NSLayoutConstraint] = [

            bannerBottomConstraint,
            banner.topAnchor.constraint(equalTo: view.topAnchor),
            banner.widthAnchor.constraint(equalToConstant: view.frame.width),

            bannerLabel.topAnchor.constraint(equalTo: banner.topAnchor, constant: 36), // this is annoying // also why 36 ?
            bannerLabel.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: 0),
            bannerLabel.centerXAnchor.constraint(equalTo: banner.centerXAnchor)

        ]

        NSLayoutConstraint.activate(constraints)

    }


    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if YZero == nil {
            YZero = scrollView.contentOffset.y
        }

//        if !refreshControl.isHidden {
//            adjustForRefresh(scrollView.contentOffset.y)
//        }


        adjustHeight()

    }

    func adjustForRefresh(_ offset: CGFloat) {

        print("not hidden")

    }

    func adjustHeight() {

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


extension ConnectVC: UICollectionViewDelegateFlowLayout {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memories.count
    }


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCell.ID, for: indexPath) as! FeedCell

        cell.indexPath = indexPath

        cell.memory = memories[indexPath.row]
        cell.setupData()
        cell.profileImageTap.addTarget(self, action: #selector(selectCell))
        cell.reallyAnnoyingTap.addTarget(self, action: #selector(selectCell))
        cell.imageTap.addTarget(self, action: #selector(selectCell))
        cell.likeButton.addTarget(self, action: #selector(likeButtonTap), for: .touchUpInside)

//        transform(cell: cell)

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

//        collectionView.visibleCells.forEach { cell in
//            transform(cell: cell)
//        }

        return cellHeights[indexPath] = cell.frame.size.height

    }


    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        print("did select")
//        selectedIndexPath = indexPath

    }


    @objc func selectCell(sender: UITapGestureRecognizer) { // open the users profile

        guard let cell = sender.view?.superview as? FeedCell else { return }

        selectedIndexPath = cell.indexPath

        let userNameLabelFrame = cell.convert(cell.userNameLabel.frame, to: nil)

        let profileImageFrame = cell.convert(cell.profileImageView.frame, to: nil)

        var willPresent = false

        if sender == cell.imageTap {

            guard cell.imageView.image != nil else { return }

            let imageFrame = cell.convert(cell.imageView.frame, to: nil)

            // TODO - make this look like the cell is just expanding instead of moving a bunch of stuff around

            VCService.presentMediaVC(imageView: cell.imageView, imageViewFrame: imageFrame, profileImageView: cell.profileImageView, profileImageViewFrame:profileImageFrame, userNameLabel: cell.userNameLabel, userNameLabelFrame: userNameLabelFrame, memory: cell.memory, author: cell.author, fromVC: self)

           willPresent = true

        } else {

            VCService.presentSelfVC(user: cell.author, fromVC: self, with: cell.profileImageView, transitionFrame: profileImageFrame)

            willPresent = true


        }


        if willPresent {

            NavView.fadeNav(toAlpha: 0)



        }



    }



    @objc func likeButtonTap(_ sender: Any) {

        guard let button = sender as? UIButton,
            let cell = button.superview as? FeedCell,
            let ref = cell.memory.ref else { return }

        if let likeRef = cell.usersLike {
            MemoryService.unlike(with: likeRef) { (completion) in
                cell.usersLike = completion
            }
        } else {
            MemoryService.like(with: ref) { (usersLike) in
                cell.usersLike = usersLike
                cell.animateLikeButton()
            }
        }

    }


    func transform(cell: UICollectionViewCell) {

        let coverFrame = cell.convert(cell.bounds, to: self.view)
        let newOffsetY = collectionView.bounds.height * (2/3)

        func getPercent(_ value: CGFloat) -> CGFloat {
            return value < 0 ? 0 : value > 1 ? 1 : value
        }

        let percent = getPercent((coverFrame.minY - newOffsetY)/(collectionView.bounds.height - newOffsetY))
        let scaleDiff: CGFloat = 0.05, scale = percent * scaleDiff

        cell.transform = CGAffineTransform(scaleX: 1-scale, y: 1-scale)

    }


// SIZE
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 8, height: 600)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }


}

extension UIImage {
    func getCropRatio() -> CGFloat {
        return CGFloat(self.size.width/self.size.height)
    }
}



extension ConnectVC {

    func fadeTopBanner(toAlpha alpha: CGFloat) {





    }

}
