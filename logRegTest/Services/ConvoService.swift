//
//  ConvoService.swift
//  logRegTest
//
//  Created by jed on 10/31/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import FirebaseFirestore
//import UserNotifications
import UIKit


class ConvoService: NSObject {

    static let convoRef = Firestore.firestore().collection("Convos")

    static func newConvo(members: [String], message: Message) {
        guard UserService.currUser != nil else { return }


        // check to see that the convo doesnt exist already
        let date = Date()
        let newConvo = Convo(ref: nil, id: nil, members: members, updatedAt: date, createdAt: date)
        var docRef: DocumentReference? = nil
            docRef = convoRef.addDocument(data: newConvo.dict) { error in
            if error != nil {
                print("ERROR - convo \(String(describing: error?.localizedDescription))")
            } else {
                if docRef != nil {
                    newMessage(docRef: docRef!, message: message)
                }
            }
        }
    }


    static func newMessage(docRef: DocumentReference, message: Message) {
        docRef.collection("messages").addDocument(data: message.dict) { error in
            if error != nil {
                print("ERROR - message \(String(describing: error?.localizedDescription))")
            } else {
                docRef.updateData(["updatedAt": message.createdAt])

                // make sure it gets returned to the user so they can view asap
                // make it return a little symbol when its done, or have it look highlighted until it uploads

            }
        }
    }

    static func checkIfExists(users: [String], completion: @escaping (_ convo: Convo?)->()) {

        var convoExists: Bool = false
        let newGroupConvo: Bool = users.count > 2

//        let arr = ["trucks", "cars", "trees"]
//        let arr2 = ["trucks", "cars", "trees"]
//        if arr == arr2 {
//            print("yay")
//        }
//        var arr3 = ["trucks", "cars", "trees", "noth"]
//        let arr4 = ["trucks", "trees", "cars"]
//        arr3.sort { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
//        if arr3 == arr4.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending } {
//            print("yay")
//        }


        func sortAlph(_ stringArr: [String]) -> [String] {
            return stringArr.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        }

        let newArr = users.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }

        if let index = MessageViewController.convos.firstIndex(where: { newArr == sortAlph($0.members) }  ) {
            let foundConvo = MessageViewController.convos[index]
            return completion(foundConvo)
        } else {
            return completion(nil)
        }

    }



}




class _Sort: NSObject {

    static func sortUsersAlphabetically(_ stringArr: [User]) -> [User] {
        return stringArr.sorted { $0.userName.localizedCaseInsensitiveCompare($1.userName) == ComparisonResult.orderedAscending }
    }

    func replaceAll<T: Equatable>(array: [T], old: T, new: T) -> [T] {
        return array.map { $0 == old ? new : $0 }
    }


}
