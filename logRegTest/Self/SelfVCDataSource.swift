//
//  SelfVCDataSource.swift
//  logRegTest
//
//  Created by jed on 11/6/18.
//  Copyright © 2018 jed. All rights reserved.
//


import UIKit
import FirebaseStorage
import FirebaseUI


extension SelfViewController: UICollectionViewDataSource {


    func loadMemories() { // also sets the user info labels . . .

        guard let uid = user.uid else { return }

        self.listener = query?.whereField("author", isEqualTo: uid).addSnapshotListener { [unowned self ] (docs, error) in
            guard let snapshot = docs else {
                print("Error fetching documents results: \(error!)")
                return
            }
            let results = snapshot.documents.map { (doc) -> Memory in
                if let memory = Memory(dict: doc.data(), ref: doc.reference, id: doc.documentID) {
                    return memory
                } else {
                    //                     return Memory(ref: nil, id: nil, author: "no", text: nil, imageUrl: "nil", likes: nil, createdAt: Date())
                    fatalError("Unable to initialize type \(Memory.self) with dictionary \(doc.data())")
                }
            }
            self.memories = results
            self.memories.sort { $0.createdAt > $1.createdAt }
            self.collectionView.reloadData()
        }
        collectionView.reloadData()
    }


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memories.count
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MediaCell
        cell.memory = memories[indexPath.row]
        return cell
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? MediaCell,
            cell.imageView.image != nil else { return }


        let frame = cell.convert(cell.imageView.frame, to: nil)

        let profileImageFrame = userCard.convert(profileImage.frame, to: nil)

//        let userNameLabelFrame = userCard.convert(userNameLabel.frame, to: nil)

        VCService.presentMediaVC(imageView: cell.imageView, imageViewFrame: frame, profileImageView: profileImage, profileImageViewFrame: profileImageFrame, userNameLabel: nil, userNameLabelFrame: nil, memory: cell.memory, author: user, fromVC: self)

        
        if primaryVC == true {
             NavView.fadeNav(toAlpha: 0)
        }

    }




}
