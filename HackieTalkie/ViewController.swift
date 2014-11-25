//
//  ViewController.swift
//  HackieTalkie
//
//  Created by Michael Brennan on 10/19/14.
//  Copyright (c) 2014 HackieTalkie. All rights reserved.
//

import UIKit
import AVFoundation
import MultipeerConnectivity

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate, NSStreamDelegate, AVAudioRecorderDelegate {
    
    @IBAction func touchingButton(sender: AnyObject) {
        if let browser = browserViewController {
            if !recorder.recording {
                recorder.prepareToRecord()

                recorder.record()
                println("Recording now")
            }
        } else {
            browserViewController = MCBrowserViewController(serviceType: serviceType, session: session)
            browserViewController.delegate = self
            
            self.presentViewController(browserViewController, animated: false, completion: nil)
        }
    }
    
    @IBAction func doubleTapped(sender: AnyObject) {
        println("Double tapped")
        if recorder.recording {
            println("Stopping Recording")
            recorder.stop()

            var error = NSErrorPointer()
            println("Contents of URL \(outputFileURL!)")
            session.sendData(NSData(contentsOfFile: outputFileURL!.path!), toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: error)
            println("Sent Data \(error)")
        }
    }
    
    var browserViewController : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session : MCSession!
    var peerID: MCPeerID!
    let serviceType = "Walkie-Talkie"
    
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    var outputFileURL: NSURL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var error = NSErrorPointer()
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, error: error)
        println("Audio Sess \(error)")
        
        let pathComponents = NSArray(objects: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last!,
            ["MyAudioMemo.m4a"].last!)
        outputFileURL = NSURL.fileURLWithPathComponents(pathComponents)

        let recordSettings = [AVFormatIDKey : kAudioFormatMPEG4AAC, AVSampleRateKey : 44100.0, AVNumberOfChannelsKey : 2]
        
        recorder = AVAudioRecorder(URL: outputFileURL, settings: recordSettings, error: error)
        println("Recorder setup \(error)")
        
        
        // Creates Peer ID and Session
        peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        session = MCSession(peer: peerID)
        session.delegate = self
        
        // Creates advertiser and hands in session
        assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
        assistant.start()
        
    }
    
    
    //    MARK: -- Browser VC Delegate Methods --
    
    // Notifies the delegate, when the user taps the done button
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Notifies delegate that the user taps the cancel button.
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    //    MARK: -- Session Delegate Methods --
    
    // Remote peer changed state
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        if state == .Connected {

        }
    }
    
    // Received a byte stream from remote peer
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    // Stream received event callback
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
    }
    
    
//    MARK: -- Unused Required Delegate Methods --
    
    // Received data from remote peer
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        println("Recieved Data \(data.length)")
        
        var error = NSErrorPointer()
        player = AVAudioPlayer(data: data, error: error)
        player.play()
        println("AVAudioPlayer setup \(error)")
    }
    
    // Start receiving a resource from remote peer
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
}