//
//  Multipeer.swift
//  logRegTest
//
//  Created by jed on 11/18/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MultipeerServiceDelegate {
    func connectedDevicesChanged(manager: MultipeerService, connectedDevices: [String])
    func aValueThatHasntBeenNamedYetChanged(manager: MultipeerService, valueString: String)
}

class MultipeerService: NSObject {

    var delegate: MultipeerServiceDelegate?

    private let serviceType = "trucks" // i dont think this is ok

    private let currPeerID = MCPeerID(displayName: UIDevice.current.name)

    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser

    lazy var session: MCSession = {
        let session = MCSession(peer: currPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    } ()

    override init() {

        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: currPeerID, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: currPeerID, serviceType: serviceType)

        super.init()

        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()

        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()

    }

    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
    }


    func sendValue(value: String) {
        NSLog("%@", "sendValue: \(value) to \(session.connectedPeers.count) peers")

        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(value.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }


}

extension MultipeerService: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")

        invitationHandler(true, self.session)

    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }

}

extension MultipeerService: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")

        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)

    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }

}

extension MultipeerService: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")

        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})

    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")

        let str = String(data: data, encoding: .utf8)!
        self.delegate?.aValueThatHasntBeenNamedYetChanged(manager: self, valueString: str)

    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }


}
