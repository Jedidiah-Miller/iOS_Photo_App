//
//  DiscoverViewController.swift
//  logRegTest
//
//  Created by jed on 10/21/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController, UICollectionViewDataSource {

    // make this onlt for memories that arent the current users

    @IBOutlet weak var banner: Gradient!
    var bannerHeight: CGFloat!
    var YZero: CGFloat!
    var bannerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: DesignableCollectionView!
    var gridLayout: GridLayout!

    @IBOutlet weak var bannerLabel: UILabel!

    var memories = [Memory]()

    var fetchingMore: Bool = false
    var endReached: Bool = false
    let leadingScreensForBatching:CGFloat = 3.0 // how many screens below the bottom
    var cellHeights: [IndexPath: CGFloat] = [:]
    var selectedIndexPath: IndexPath!

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = .gray
        refreshControl.backgroundColor = .clear
        return refreshControl
    } ()


    // DISABLE THE LISTENER WHEN AFTER IT LOADS

    // there was an issue when you open a photo and new uploads were made, it put the return photo back in the same cell but the cells had changed

    // also // the transitions sometime bring the 

    override func viewDidLoad() {
        super.viewDidLoad()

        setupConstraints()
        bannerLabel.layer.shadowOpacity = 1
        bannerLabel.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        bannerLabel.layer.shadowRadius = 1
        bannerLabel.layer.shadowOffset = CGSize(width: 0, height: 0)

        collectionView.contentInset.top = bannerHeight/2
        collectionView.contentInset.bottom = bannerHeight
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true

        MemoryService.query = MemoryService.baseQuery() // idk

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.refreshControl = refreshControl // this fucks shit up

        self.view.accessibilityIgnoresInvertColors = true

        gridLayout = GridLayout(numberOfColumns: 3, cellPadding: 0.5)

        collectionView.collectionViewLayout = gridLayout
        collectionView.backgroundColor = .white
        collectionView.reloadData()

        memories = []
        getMemories()

    }

    @objc func handleRefresh() {
        self.endReached = false
        getMemories()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl.endRefreshing()
        }

    }

    func getMemories() {

        MemoryService.getMemories(discover: true, memories: self.memories) { updated in

            if let newMemories = updated, !newMemories.isEmpty {

                self.memories = newMemories

                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }



        }

    }
    

    func beginBatchFetch() {
        fetchingMore = true
        self.collectionView.reloadSections(IndexSet(integer: 0) )
        MemoryService.observe( memories: memories ) { newMemories in
            self.memories.append(contentsOf: newMemories)
            self.fetchingMore = false
            self.endReached = newMemories.count == 0

            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }



}


extension DiscoverViewController: UICollectionViewDelegate {


    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        collectionView.visibleCells.forEach { cell in
            transform(cell: cell)
        }

        adjustHeight()

        let offsetY = scrollView.contentOffset.y,
        contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.size.height * leadingScreensForBatching {
            if !fetchingMore && !endReached {
                //                beginBatchFetch()
            }
        }
    }

    func adjustHeight() {

        if YZero == nil {
            YZero = collectionView.contentOffset.y
        }

        let diffY = (YZero - collectionView.contentOffset.y), // how much scroll view has changed
        bottomConstraint = (bannerHeight - view.frame.height) + diffY

        guard bottomConstraint >= bannerHeight - view.frame.height else {

            if bannerBottomConstraint.constant != bannerHeight - view.frame.height {
                bannerBottomConstraint.constant = bannerHeight - view.frame.height
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                })
            }

            return
        }

        bannerBottomConstraint.constant = bottomConstraint

    }

    func transform(cell: UICollectionViewCell) {

        let coverFrame = cell.convert(cell.bounds, to: self.view)
        let newOffsetY = collectionView.bounds.height * (2/3)

        func getPercent(_ value: CGFloat) -> CGFloat {
            return value < 0 ? 0 : value > 1 ? 1 : value
        }

        let percent = getPercent((coverFrame.minY - newOffsetY)/(collectionView.bounds.height - newOffsetY))
        let maxDiff: CGFloat = 0.333, scale = percent * maxDiff

//        cell.transform = CGAffineTransform(scaleX: 1-scale, y: 1-scale)
        cell.alpha = 1-scale

    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if section == 0 {
            return memories.count
        } else {
            return fetchingMore ? 1 : 0
        }

    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as? MediaCell else { return UICollectionViewCell() }

        cell.memory = memories[indexPath.row]

        transform(cell: cell)

        return cell

    }


//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
////        return cellHeights[indexPath] = cell.frame.size.height
//    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath) as! MediaCell

        guard cell.imageView.image != nil, cell.memory != nil else {
            return
        }

        selectedIndexPath = indexPath

        let imageFrame = cell.convert(cell.imageView.frame, to: nil)

        NavView.fadeNav(toAlpha: 0)

        VCService.presentMediaVC(imageView: cell.imageView, imageViewFrame: imageFrame, profileImageView: nil, profileImageViewFrame: nil, userNameLabel: nil, userNameLabelFrame: nil, memory: cell.memory, author: nil, fromVC: self)




    }

}



// MARK ! - constraints

extension DiscoverViewController {

    func setupConstraints() {

        banner.translatesAutoresizingMaskIntoConstraints = false
        bannerHeight = 80 // view.safeAreaInset.top * 1.8
        bannerBottomConstraint = banner.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bannerHeight - view.frame.height)

        let constraints: [NSLayoutConstraint] = [

            bannerBottomConstraint,
            banner.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            //            banner.heightAnchor.constraint(greaterThanOrEqualToConstant: bannerHeight),
            banner.widthAnchor.constraint(equalToConstant: view.frame.width)

        ]

        NSLayoutConstraint.activate(constraints)

        bannerLabel.constraints.forEach { const in
            print("constraint - \(const)")
        }

    }


}
