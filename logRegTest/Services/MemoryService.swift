//
//  MemoryService.swift
//  logRegTest
//
//  Created by jed on 10/11/18.
//  Copyright © 2018 jed. All rights reserved.
//


import FirebaseFirestore
//import CoreLocation


class MemoryService: NSObject {

    static var memoryList = [Memory]()
    static var CurrUsers = [Memory]()

    static let ref = Firestore.firestore().collection("Memories")


    static var listener: ListenerRegistration!

    static func baseQuery() -> Query {
        return Firestore.firestore().collection("Memories")
    }

    // THESE WILL CHANGE ALL THE TIME FIX THIS

    static var query: Query? {
        didSet {
//            if let listener = listener {
//                listener.remove()
//            } else {
//                print("!!!!!!!! this shouldnt have changed again !!!!!!!!!!")
//            }
        }
    }

    deinit {
        MemoryService.listener.remove()
    }


    static func getMemories(discover: Bool, memories: [Memory], completion: @escaping (_ updatedMemories:[Memory]?)->()) {

//        let last = memories.last

        var query: Query?

//        if let last = last {
//            query = baseQuery().order(by: "createdAt", descending: true).end(at: [last])
//        } else if last == nil {
            query = baseQuery().limit(to: 50)
//        }

        self.listener = query?.addSnapshotListener { (docs, error) in
            guard let snapshot = docs else {
                print("Error fetching documents results: \(error!)")
                return
            }

            var memoryArr = [Memory]()

            memoryList = snapshot.documents.map { (doc) -> Memory in
                if let memory = Memory(dict: doc.data(), ref: doc.reference, id: doc.documentID) {

                    let following: Bool = UserService.following?.contains(memory.author) ?? false
                    let currUsers: Bool = UserService.currUser.uid == memory.author

                    switch discover {

                    case true:
                        if !following && !currUsers {
                            memoryArr.append(memory)
                        }

                    case false:
                        if following || currUsers {
                            memoryArr.append(memory)
                        }

                    }


                    return memory
                } else {
                    fatalError("Unable to initialize type \(Memory.self) with dictionary \(doc.data())")
                }
            }
            completion(memoryArr)
        }

    }



    static func observe(memories: [Memory], completion: @escaping (_ updatedMemories:[Memory])->()) {

        let last = memories.last

        var query: Query?

        if let last = last {
            query = baseQuery().order(by: "createdAt", descending: true).end(at: [last])
        } else if last == nil {
            query = baseQuery().order(by: "createdAt", descending: true).limit(to: 20)
        }


        self.listener = query?.addSnapshotListener { (docs, error) in
            guard let snapshot = docs else {
                print("Error fetching documents results: \(error!)")
                return
            }

            let results = snapshot.documents.map { (doc) -> Memory in
                if let memory = Memory(dict: doc.data(), ref: doc.reference, id: doc.documentID) {
                    memoryList.append(memory)
                    return memory
                } else {
                    fatalError("Unable to initialize type \(Memory.self) with dictionary \(doc.data())")
                }
            }

            completion(results)

        }

    }


    static func createMemory(text: String, imageUrl: URL) {

        guard let uid = UserService.currUser.uid else { return }
        let text = text == "" ? nil : text
        let memory = Memory(ref: nil, id: nil,
                            author: uid,
                            text: text,
                            imageUrl: imageUrl.absoluteString,
                            likes: nil,
                            createdAt: Date()
                        )

        ref.addDocument(data: memory.dict) { error in
            if error != nil {
                print("ERROR - message \(String(describing: error?.localizedDescription))")
            } else {
                print("success !!! new memory created")
            }
        }
        
    }


    static func getLikes(with ref: DocumentReference, completion: @escaping (_ likes:[Like]?)->(), usersLike: @escaping (_ usersLike: DocumentReference?)->()) {

        ref.collection("Likes").addSnapshotListener { /* [unowned self ] */ (docs, error) in

            guard let snapshot = docs else {
                print("Error fetching documents results: \(error!)")
                return
            }

            let results = snapshot.documents.map { doc -> Like in
                if let like = Like(dict: doc.data(), ref: doc.reference, id: doc.documentID) {
                    like.uid == UserService.currUser.uid ? usersLike(like.ref) : nil
                    return like
                } else {
                    fatalError("Unable to initialize type \(Like.self) with dictionary \(doc.data())")
                }
            }
             completion(results)
        }

    }


    static func like(with ref: DocumentReference, completion: @escaping ( _ usersLike: DocumentReference?)->()) {

        guard let uid = UserService.currUser.uid else { return }

        let like = Like(ref: nil, id: nil, uid: uid, createdAt: Date())

        var likeRef: DocumentReference?

        likeRef = ref.collection("Likes").addDocument(data: like.dict ) { error in
            if let error = error {
                print("ERROR - message \(String(describing: error.localizedDescription))")
            } else {
                if let likeRef = likeRef {
                    completion(likeRef)
                }
            }
        }
    }


    static func unlike(with ref: DocumentReference, completion: @escaping (_ newRef:DocumentReference? )->()) {

        guard UserService.currUser.uid != nil else { return }

        ref.delete { (error) in
            if let error = error {
                print("ERROR - message \(String(describing: error.localizedDescription))")
                completion(ref)
            } else {
                completion(nil)
            }
        }

    }



    static func delete(with ref: DocumentReference, completion: @escaping (_ error: String? )->()) {

        guard UserService.currUser.uid != nil else { return }

        ref.delete { (error) in
            if let error = error {
                print("ERROR - ", error.localizedDescription)
                completion(error.localizedDescription)
            } else {
                completion(nil)
            }
        }

    }


}


