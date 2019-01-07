//
//  ImageService.swift
//  logRegTest
//
//  Created by jed on 10/20/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit
import FirebaseStorage

class ImageService {


    static let cache = NSCache<NSString, UIImage>()

    static func addImage(_ image: UIImage, loc: String, progressBlock: @escaping (_ precentage: Double)-> Void , completion: @escaping (_ url:URL?, _ error: String?) -> Void  )  {

        guard let uid = UserService.currUser?.uid else { return }

        let imageName = "\(Date())",
            storageRef = Storage.storage().reference().child("users").child(uid).child(loc).child(imageName)

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"

            let task = storageRef.putData( imageData, metadata: metadata, completion: { (metadata, error) in
                if error == nil, metadata != nil {
                    storageRef.downloadURL { url, error in
                        completion(url, nil)
                    }
                } else {
                    print("uplaod error - ", error?.localizedDescription as Any)
                    completion(nil, error?.localizedDescription)
                }
            })

            task.observe(.progress, handler: { (snapshot) in
                guard let progress = snapshot.progress else { return }
                let percentage = Double(progress.completedUnitCount) / Double(progress.totalUnitCount) * 100
                progressBlock(percentage)
            })
        } else {
            completion(nil, "wtf happened yo " )
        }
    }



}
