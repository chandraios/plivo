//
//  ViewController.swift
//  PlivoSampleApp
//
//  Created by Parlapalli on 20/07/18.
//  Copyright © 2018 UTU. All rights reserved.
//

import UIKit
import CallKit
 import PushKit

class ViewController: UIViewController, PlivoEndpointDelegate, UITextFieldDelegate{
    @IBOutlet weak var answerButton: UIButton!
    var phone:Phone? = nil
    var incCall:PlivoIncoming? = nil
    
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var callLog: UILabel!
    @IBOutlet weak var hangupButton: UIButton!
    @IBAction func answer(_ sender: Any) {
        logDebug(message:  "- Answering call")
        if ((self.incCall) != nil) {
            self.incCall?.answer()
            self.answerButton.isEnabled = false
        }
    }
    @IBAction func hangup(_ sender: Any) {
        logDebug(message: "- Hangup call")
        if ((self.incCall) != nil) {
            self.incCall?.hangup()
        }
        resetUI()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        logTextView.text = "- Logging in\n"
        self.phone!.login()
        self.resetUI()
        //logTextView.delegate = self as! UITextViewDelegate
        self.callLog.text = "" 
 
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    func logDebug(message: NSString) {
        if (!Thread.isMainThread)
        {
            DispatchQueue.main.async(execute:
                {
                    let toLog = String.init(format:  "%@\n", message)
                    self.logTextView.insertText(toLog)
                    self.logTextView.scrollRangeToVisible(NSMakeRange(self.logTextView.text.lengthOfBytes(using: String.Encoding.ascii), 0))
                    return
            })

            
        }

        
    }
    func resetUI() {
        answerButton.isEnabled = false
        hangupButton.isEnabled = false
        OperationQueue.main.addOperation {
            self.callLog.text = ""
        }
 
    }
 
    func onLogin() {
        logDebug(message: "- Login OK")
        logDebug(message: "- Ready to receive a call")
    }
    
    func onLoginFailed() {
        logDebug(message: "- Login failed. Please check your username and password")
    }
    func onIncomingCall(_ incoming: PlivoIncoming!) {
        
        OperationQueue.main.addOperation {
            self.callLog.text = incoming.fromContact
            var logMsg = String.init(format: "- Call from %@", incoming.fromContact)
            self.logDebug(message: logMsg as NSString)
            self.incCall = incoming
        }
        answerButton.isEnabled = true
        hangupButton.isEnabled = true
        
        if (incoming.extraHeaders.count > 0){
            logDebug(message: "- Extra headers:")
            for (key,value) in incoming.extraHeaders {
                //var val = incoming.extraHeaders.o(key)
                var keyVal = String.init(format: "-- %@ => %@", key as CVarArg, value as! CVarArg)
                logDebug(message: keyVal as NSString)
            }
        }
    }
    func onIncomingCallHangup(_ incoming: PlivoIncoming!) {
        logDebug(message: "- Incoming call ended")
        resetUI()
    }
    func onIncomingCallRejected(_ incoming: PlivoIncoming!) {
        logDebug(message: "- Incoming call rejected")
        resetUI()
    }
 
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // configure audio session
        action.fulfill()
    }
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, forType type: PKPushType) {
        if let uuidString = payload.dictionaryPayload["UUID"] as? String,
            let identifier = payload.dictionaryPayload["identifier"] as? String,
            let uuid = UUID(uuidString: uuidString)
        {
            let update = CXCallUpdate()
            //update.callerIdentifier = identifier
            let conf: CXProviderConfiguration = CXProviderConfiguration.init(localizedName: "call")
            let provider: CXProvider = CXProvider.init(configuration: conf)
            provider.reportNewIncomingCall(with: uuid, update: update) { error in
                print(error?.localizedDescription ?? "error")
            }
        }    }

}

