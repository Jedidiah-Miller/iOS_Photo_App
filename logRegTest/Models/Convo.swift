//
//  ChatMessage.swift
//  logRegTest
//
//  Created by jed on 11/1/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import FirebaseFirestore


struct Convo {
    var
    ref: DocumentReference!,
    id: String!,
    members:[String],
    updatedAt: Date,
    createdAt: Date

    var dict:[String: Any] {
        return [
            "members": members,
            "updatedAt": updatedAt,
            "createdAt": createdAt,
        ]
    }
}

extension Convo {
    init?(dict: [String: Any], ref: DocumentReference, id: String) {
        guard
            let members = dict["members"] as? [String],
            let updatedAt = dict["updatedAt"] as? Date,
            let createdAt = dict["createdAt"] as? Date
            else { return nil }

        self.init (
            ref: ref,
            id: id,
            members: members,
            updatedAt: updatedAt,
            createdAt: createdAt
        )
    }
}


struct Message {
    var
    id: DocumentReference?,
    sender:String,
    content:String,
    createdAt: Date

    var dict:[String:Any] {
        return [
            "sender": sender,
            "content": content,
            "createdAt": createdAt
        ]
    }
}

extension Message {
    init?(dict: [String: Any], id: DocumentReference? ) {
        guard
            let sender = dict["sender"] as? String,
            let content = dict["content"] as? String,
            let createdAt = dict["createdAt"] as? Date
            else { return nil }

        self.init( id: id,
                   sender: sender,
                   content: content,
                   createdAt: createdAt
        )

    }
}
