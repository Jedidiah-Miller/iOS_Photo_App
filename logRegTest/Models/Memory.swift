//
//  Post.swift
//  logRegTest
//
//  Created by jed on 7/7/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Memory {
    var
        ref: DocumentReference?,
        id: String!,
        author: String
    var text: String?

    var imageUrl: String,
        likes: [Like]?,
        createdAt: Date

    var dict: [String: Any] { // terrible

        if let text = text { // text // no likes
            return [
                "author": author,
                "imageUrl": imageUrl,
                "text": text,
                "createdAt": createdAt
            ]
        } else {
            return [
                "author": author,
                "imageUrl": imageUrl,
                "createdAt": createdAt
            ]
        }
    }
}

extension Memory {
    init?(dict: [String: Any], ref: DocumentReference?, id: String) {
        guard
            let author = dict["author"] as? String,
            let text = dict["text"] as? String?,
            let imageUrl = dict["imageUrl"] as? String,
            let likes = dict["likes"] as? [Like]?,
            let createdAt = dict["createdAt"] as? Date
            else { return nil }


        self.init(ref: ref,
                  id: id,
                  author: author,
                  text: text,
                  imageUrl: imageUrl,
                  likes: likes,
                  createdAt: createdAt
        )
    }
}


struct Like {
    var
        ref: DocumentReference!,
        id: String!,
        uid: String,
        createdAt: Date

    var dict: [String: Any] {
        return [
            "uid": uid,
            "createdAt": createdAt
        ]
    }
}

extension Like {
    init?(dict: [String: Any], ref: DocumentReference, id: String) {
        guard
            let uid = dict["uid"] as? String,
            let createdAt = dict["createdAt"] as? Date
            else { return nil }


        self.init(ref: ref,
                  id: id,
                  uid: uid,
                  createdAt: createdAt
        )
    }
}


