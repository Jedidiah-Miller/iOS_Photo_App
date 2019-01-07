//
//  User.swift
//  logRegTest
//
//  Created by jed on 10/30/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct User {
    var
        ref: DocumentReference!,
        uid: String!,
        email: String,
        userName:String,
        bio: String?,
        profileImage: String?,          // save the StorageReference
        accountCreatedAt: Date

    var dict:[String:Any] {
        return [
            "email": email,
            "userName": userName,
            "accountCreatedAt" : accountCreatedAt
        ]
    }
}

extension User {
    init?(dict: [String: Any], ref: DocumentReference, uid:String) {
        guard
            let email = dict["email"] as? String,
            let userName = dict["userName"] as? String,
            let bio = dict["bio"] as? String?,
            let profileImage = dict["profileImage"] as? String?,        // save the StorageReference
            let accountCreatedAt = dict["accountCreatedAt"] as? Date
            else { return nil }

        self.init(ref:ref,
                  uid: uid,
                  email: email,
                  userName: userName,
                  bio: bio,
                  profileImage: profileImage,
                  accountCreatedAt: accountCreatedAt
        )
    }
}

