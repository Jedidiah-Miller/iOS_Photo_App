//
//  UserService.swift
//  logRegTest
//
//  Created by jed on 7/7/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseUI

class UserService {

    static let defaultsKeyForDict: String = "UserDict"

    static var currUser: User! {
        didSet {

            guard currUser != nil else {

                following = nil
                followers = nil

                return
            }


            if currUser.profileImage != nil {
                currUserImage = UIImage()
            }

            getFollows(with: currUser.ref, followers: { (followers) in
                self.followers = followers
            }) { (following) in
                self.following = following
            }

        }
    }

    static var followers: [String]?
    static var following: [String]?

//    static var userImage: UIImage? {
//        get {
//
//        }
//    }

    static var currUserImage: UIImage? {
        didSet {
            let view = UIImageView(),
            ref = Storage.storage().reference(forURL: currUser.profileImage!)
            view.sd_setImage(with: ref)
            currUserImage = view.image
        }
    }

    static func getCurrUserImage() -> UIImage? {
        guard currUserImage == nil else { return currUserImage }
        guard let url = currUser?.profileImage else { return nil }

        let view = UIImageView(),
        ref = Storage.storage().reference(forURL: url)
        view.sd_setImage(with: ref)
        return view.image
    }


    static var storedUsers: [User] = [] // has duplicates occasionally

    static let ref = Firestore.firestore().collection("Users")


    // MARK ! - there is no create user here
    // should only ever be done in the loginVC so that's where it is


    static func findOrObserve(_ uid:String, completion: @escaping ((_ user:User)->())) {

        if let index = storedUsers.index( where: { $0.uid == uid }) {
            let foundUser = storedUsers[index]
            print("Found a user")
            completion(foundUser)
        } else {
            observe(uid, completion: { (user) in
                if let user = user {
                    // make it check again to not add duplicates
                    storedUsers.append(user)
                    print("had to get a user from DB")
                    completion(user)
                }
            })
        }

    }


    static func observe(_ uid:String, completion: @escaping ((_ thisUser:User?)->())) {

        ref.document(uid).addSnapshotListener { (doc, error) in

            guard error == nil, let snap = doc else {

                print(error!.localizedDescription)

                return completion(nil)
            }


            if let data = snap.data() {

                let user = User(dict: data, ref: snap.reference, uid: snap.documentID)

                return completion(user)

            } else {

                print("snap ID for a nonexistant user -", snap.documentID)

                return completion(nil)

            }


        }


    }


    static func getUserDoc(_ uid:String, completion: @escaping ((_ thisUser:User?)->())) {

        ref.document(uid).getDocument { (doc, error) in
            guard let snap = doc, let data = snap.data(),
                let user = User(dict: data, ref: snap.reference, uid: snap.documentID)  else {
                    print("ERROR ! - \(error!.localizedDescription)")
                    return completion(nil)
            }
            return completion(user)
        }

    }




    static func getFollows(with userRef: DocumentReference, followers: @escaping (_ followers:[String]?)->(), following: @escaping (_ following: [String]?)->()) {

        userRef.collection("Following").addSnapshotListener { (docs, error) in
            guard let snapshot = docs else {
                print("ERROR - \(error!.localizedDescription) " )
                return
            }
            var followingArr: [String] = []
            snapshot.documents.forEach({ (doc) in
                followingArr.append(doc.documentID)
            })
            following(followingArr)
        }

        userRef.collection("Followers").addSnapshotListener { (docs, error) in
            guard let snapshot = docs else {
                print("ERROR - \(error!.localizedDescription) " )
                return
            }
            var followersArr: [String] = []
            snapshot.documents.forEach({ (doc) in
                followersArr.append(doc.documentID)
            })
            followers(followersArr)
        }

    }


    static func update(_ fields: [String: Any], completion: @escaping ((_ error: Error?)->())) {

        currUser.ref.updateData(fields) { (error) in
            if error != nil {
                print("ERROR - SET Image \(error!.localizedDescription)")
                return completion(error)
            } else {
                completion(nil)
            }
        }

    }


    static func checkUserName(_ userName: String, completion: @escaping ((_ exists: Bool)->())) {

        var listener: ListenerRegistration?
        var exists = false

        listener = ref.whereField("lowercasedName", isEqualTo: userName.lowercased()).addSnapshotListener { (docs, error) in

            docs?.isEmpty == false ? exists = true : nil

            return completion(exists)

        }

        if let listener = listener {

            print("LISTENER - ", listener.description)

        }

//        listener?.remove()
    }



    static func resetPassword(_ email: String, completion: @escaping ((_ error: Error?)->())) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }


    static func setProfileImage(imageUrl: URL, completion: @escaping ((_ error: Error?)->())) {
        guard let ref = UserService.currUser.ref else { return }
        ref.updateData(["profileImage": imageUrl.absoluteString]) { (error) in
            if error != nil {
                print("ERROR - SET Image \(error!.localizedDescription)")
                return completion(error)
            } else {
                return completion(nil)
            }
        }
    }



    static func follow(user: User, completion: @escaping ((_ error: Error?)->())) {
        guard let currUser = currUser else { return }

        currUser.ref.collection("Following").document(user.uid).setData(["followedAt":Date()]) { (error) in
            if let error = error {
                print("ERROR - \(error.localizedDescription)")
                completion(error)
            } else {
                user.ref.collection("Followers").document(currUser.uid).setData(["followedAt":Date()]) { (error) in
                    if let error = error {
                        print("ERROR - \(error.localizedDescription)")
                        completion(error)
                    } else {
                        following?.append(user.uid)
                        completion(nil)
                    }
                }
            }
        }
    }


    static func unFollow(user: User, completion: @escaping ((_ error: Error?)->())) {
        guard let currUser = currUser else { return }

        currUser.ref.collection("Following").document(user.uid).delete() { (error) in
            if let error = error {
                print("ERROR - \(error.localizedDescription)")
                completion(error)
            } else {
                user.ref.collection("Followers").document(currUser.uid).delete() { (error) in
                    if let error = error {
                        print("ERROR - \(error.localizedDescription)")
                        completion(error)
                    } else {
                        if let i = following?.index(where: { $0 == user.uid }) {
                            following?.remove(at: i)
                        }
                        completion(nil)
                    }
                }
            }
        }

    }


    static func search(_ string:String?, completion: @escaping ((_ users:[User]?)->())) {

//        let ref = Firestore.firestore().collection("Users").whereField("userName", isEqualTo: string)
//        let ref = Firestore.firestore().collection("Users").whereField("userName", isLessThanOrEqualTo: string)

        let ref = Firestore.firestore().collection("Users")

        ref.addSnapshotListener { (docs, error) in

            guard let snap = docs else { return }

            let results = snap.documents.map { (doc) -> User in
                if let message = User(dict: doc.data(), ref: doc.reference, uid: doc.documentID) {
                    return message
                } else {
                    fatalError("Unable to initialize type \(User.self) with dictionary \(doc.data())")
                }
            }
            return completion(results)

        }

    }





    static func signOut() {

        // (completion: @escaping ((_ error: Error?)->()))

        do {

            try Auth.auth().signOut()





        } catch let error {
//            completion(error)
            print(error.localizedDescription)

        }



    }



}
