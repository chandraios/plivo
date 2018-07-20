//
//  Phone.swift
//  PlivoSampleApp
//
//  Created by Parlapalli on 20/07/18.
//  Copyright © 2018 UTU. All rights reserved.
//

import Foundation

class Phone: NSObject  {
    var endpoint:PlivoEndpoint
    
    override  init() {
        endpoint = PlivoEndpoint.init()
        super.init()
    }
    
    func login() {
        let username = "chandra250180720051329"
        let password = "AmmaNanna9"
        
        endpoint.login(username, andPassword: password)
    }
    
    func setDelegate(delegate:Any) {
        endpoint.delegate = delegate as AnyObject
    }
    
    func keepAlive() {
        endpoint.keepAlive()
    }
}




