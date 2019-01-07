//
//  GridLayout.swift
//  logRegTest
//
//  Created by jed on 10/20/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit


class GridLayout: UICollectionViewFlowLayout {

    var numberOfColumns: Int = 3,
        cellPadding: CGFloat = 2

    init(numberOfColumns: Int,
         cellPadding: CGFloat
        ) {
        super.init()
        minimumLineSpacing = cellPadding
        minimumInteritemSpacing = cellPadding

        self.numberOfColumns = numberOfColumns
        self.cellPadding = cellPadding
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func itemHeight() -> CGFloat {
        return 260
    }

    override var itemSize: CGSize {
        get {
            if let collectionView = collectionView {
                let itemWidth: CGFloat = (collectionView.frame.width/CGFloat(self.numberOfColumns)) - self.minimumInteritemSpacing
                return CGSize(width: itemWidth, height: itemHeight())
            }
            return CGSize(width: 100, height: 100)
        }
        set {
            super.itemSize = newValue
        }
    }

    func itemSizeFor(_ columnSize: Int, with height: CGFloat = 260.0) -> CGSize {
        guard let collectionView = collectionView else {
            return .zero
        }

        if columnSize == 1 {
            let itemWidth: CGFloat = collectionView.frame.width - self.minimumInteritemSpacing
            return CGSize(width: itemWidth, height: height)
        } else if columnSize == 2 {
            let itemWidth: CGFloat = (collectionView.frame.width/CGFloat(self.numberOfColumns)) - self.minimumInteritemSpacing
            return CGSize(width: itemWidth, height: height)
        }

        return .zero
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return proposedContentOffset
    }

}
