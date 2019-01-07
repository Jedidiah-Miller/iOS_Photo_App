//
//  MediaCell.swift
//  logRegTest
//
//  Created by jed on 10/21/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseUI

class MediaCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    var memory: Memory! {
        didSet {
            let ref = Storage.storage().reference(forURL: memory.imageUrl)
            imageView.sd_setImage(with: ref, placeholderImage: nil)
        }
    }

    var absolutePosition: CGRect!

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 8
        imageView.layer.cornerRadius = layer.cornerRadius

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

    }

    // MARK: - make a loading image like a shiney thing


}

