//
//  MessagesDataSource.swift
//  logRegTest
//
//  Created by jed on 11/8/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit


extension MessageViewController: UITableViewDelegate, UITableViewDataSource {

    func getConvos() {

        guard let user = UserService.currUser!.uid else { return }

        self.listener =  query?.whereField("members", arrayContains: user).addSnapshotListener { [unowned self ] (docs, error) in

            guard let snapshot = docs?.documentChanges else {
                print("Error fetching documents results: \(error!)")
                return
            }

            let results = snapshot.map { (doc) -> Convo in
                if let convo = Convo(dict: doc.document.data(), ref: doc.document.reference, id: doc.document.documentID) {
                    return convo
                } else {
                    fatalError("Unable to initialize type \(Convo.self) with dictionary \(doc.document.data())")
                }
            }


            DispatchQueue.main.async {

                self.checkNewConvos(results)

                MessageViewController.convos.sort { $0.updatedAt > $1.updatedAt }

                self.tableView.reloadData()

            }


        }

    }

    func checkNewConvos(_ convos:[Convo]) {

        convos.forEach { convo in

            // if the convo is just an update of an existing convo
            if let index = MessageViewController.convos.index(where: { $0.id == convo.id }) {

                // set the existing convo to the updated convo
                MessageViewController.convos[index] = convo

            } else {

                // if its a convo that hasnt been added yet
                // typically for initial fetch
                MessageViewController.convos.append(convo)

            }

        }

    }



    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageViewController.convos.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ConvoTableViewCell
        cell.convo = MessageViewController.convos[indexPath.row]
        cell.setupLabel()
        cell.selectionStyle = .gray

        return cell

    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        guard let cell = tableView.cellForRow(at: indexPath) as? ConvoTableViewCell,
            let convo = cell.convo else { return }


        VCService.presentConvoVC(users: cell.members, fromVC: self, convo: convo)

    }




//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "ToConvo" {
//
//            if let selected = sender as? SelectedConvo, let destination = segue.destination as? ConvoVC {
//
//                destination.selectedConvo = selected
//
//            }
//        }
//
//    }




    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollCenter == nil {
            scrollCenter = tableView.contentOffset.y
        }

        adjustHeight()

    }


    func adjustHeight() {

        let diffY = (scrollCenter - tableView.contentOffset.y), // how much scroll view has changed
            bottomConstraint = (chatBannerheight - view.frame.height) + diffY

        guard bottomConstraint >= chatBannerheight - view.frame.height else {

            if chatBannerBottomConstraint.constant != chatBannerheight - view.frame.height {
                chatBannerBottomConstraint.constant = chatBannerheight - view.frame.height
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                })
            }

            return
        }

        chatBannerBottomConstraint.constant = bottomConstraint

    }


    
}

