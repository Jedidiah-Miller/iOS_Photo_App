//
//  ConvoDataSource.swift
//  logRegTest
//
//  Created by jed on 11/5/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit
import FirebaseFirestore


extension ConvoVC: UITableViewDataSource {



    func loadMessages() {

        var shouldAnimate = false

        self.listener = selectedConvo.convo.ref.collection("messages").order(by: "createdAt", descending: false).addSnapshotListener { [unowned self] (docs, error) in

            guard let snap = docs?.documentChanges else { print("ERROR: - \(error!.localizedDescription)"); return }

            let results = snap.map { (doc) -> Message in
                if let message = Message(dict: doc.document.data(), id: doc.document.reference) {
                    return message
                } else {
                    fatalError("Unable to initialize type \(Message.self) with dictionary \(doc.document.data())")
                }
            }


            DispatchQueue.main.async {

                self.groupBySender(results.sorted { $0.createdAt < $1.createdAt } )

//                shouldAnimate ? self.reloadNewMessages() : self.messageView.reloadData()

                self.messageView.reloadData()

                self.scrollToBottom(animated: shouldAnimate)

                 print("this convo has already loaded = ", shouldAnimate)

                shouldAnimate = true

            }


        }


    }




    func groupBySender(_ messages : [Message]) {
        // MARK - messages are sorted by createdtAt already

        var userArr: [Message] = []
        let lastGroup: [Message]? = self.messages.last

        messages.forEach { message in

            if message.id != lastGroup?.last?.id, message.id != userArr.last?.id { // not a duplicate, idk why this happens
                
                if message.sender == lastGroup?.last?.sender { // for new messages after initial load

                    self.messages[self.messages.count - 1].append(message)

                } else if message.sender == userArr.last?.sender || userArr.isEmpty  {

                    userArr.append(message)

                } else { // this messages sender is not equal to the arrays sender

                    self.messages.append(userArr) // add the new array

                    userArr = [] // clear the current array for reuse
                    userArr.append(message) // add the new message to the array

                }
            } else {
                print("found a duplicate")
            }

        }


        !userArr.isEmpty ? self.messages.append(userArr) : nil

    }


    // gets called after the messages are initially loaded
    // more importantly, this fucks shit up

    func reloadNewMessages() {

        messageView.reloadRows(at: [lastIndexPath], with: .fade)

    }


    func scrollToBottom(animated: Bool) {

        guard messages.count > 0 else { return }

//        let lastIndexPath = IndexPath(row: messages[messages.count - 1].count - 1, section: messages.count - 1) // last index path

        let duration: Double = animated ? 0.2 : 0

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            self.messageView.scrollToRow(at: self.lastIndexPath, at: .bottom, animated: false)
        })

    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return self.messages.count
    }


    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard selectedConvo.members.count > 2,
            let uid = messages[section].first?.sender,
            let indexForName = selectedConvo.members.index(where: { $0.uid == uid } ),
            let currUserUid = UserService.currUser.uid else { return nil }

        let outgoing: Bool = uid == currUserUid
        let dividerView = DividerView()
        dividerView.outgoing = outgoing
        dividerView.label.text = outgoing ? "You" : selectedConvo.members[indexForName].userName
        return dividerView

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return selectedConvo.members.count > 2 ? 14 : 0 // don't like it but it works really well
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: messageCellID, for: indexPath) as! MessageCell
        cell.message = messages[indexPath.section][indexPath.row]
        return cell
    }

//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//    }



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: messageCellID, for: indexPath) as? MessageCell,
            let message = cell.message else { return }

        print("THIS CELLS MESSAGE \(message)")



//        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
//        tableView.deselectRow(at: indexPath, animated: false)

    }

}



class DividerView: UIView {

    var outgoing: Bool! {
        didSet {
            let colors = [ #colorLiteral(red: 1, green: 0.5968740582, blue: 0.03151972219, alpha: 1), #colorLiteral(red: 0.9707821012, green: 1, blue: 0.986733377, alpha: 0) ]
            divider.FirstColor = outgoing ? colors[1] : colors[0]
            divider.SecondColor = outgoing ? colors[0] : colors[1]
            let X: [CGFloat] = outgoing ? [0.5, 1] : [0, 0.5]
            divider.startPoint = CGPoint(x: X[0], y: 0)
            divider.endPoint = CGPoint(x: X[1], y: 0)
            labelLeadingConstraint.isActive = !outgoing
            labeltrailingConstraint.isActive = outgoing
        }
    }

    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 10)
        return label
    }()

    lazy var labelLeadingConstraint: NSLayoutConstraint = {
        return label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 6)
    }()

    lazy var labeltrailingConstraint: NSLayoutConstraint = {
        return label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -6)
    }()

//    let image: UIImage = {
//        let image = UIImage()
//        return image
//    }()

    lazy var divider: Gradient = {
        let divider = Gradient()
        divider.layer.backgroundColor = UIColor.clear.cgColor
        divider.backgroundColor = .clear
        return divider
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)

        [divider,label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        backgroundColor = .clear

        let constraints: [NSLayoutConstraint] = [

            divider.heightAnchor.constraint(equalToConstant: 0.7),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),

            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]

        NSLayoutConstraint.activate(constraints)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
