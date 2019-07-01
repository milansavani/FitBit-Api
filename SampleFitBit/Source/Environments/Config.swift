//
//  Config.swift
//  SampleFitBit
//
//  Created by mobiiworld on 27/06/19.
//  Copyright © 2019 mobiiworld. All rights reserved.
//

import Foundation

class Config {
    static var shared = Config()
    var infoList = [String: Any]()
    
    var domain: String
    var authURL: String
    var fitbitClientID: String
    var fitbitClientSecret: String
    var appURI: String
    
    private init() {
        if let info = Bundle.main.infoDictionary {
            infoList = info
        }
        domain = infoList["ROOT_URL"] as! String
        fitbitClientID = infoList["FITBIT_CLIENT_ID"] as! String
        fitbitClientSecret = infoList["FITBIT_CLIENT_SECRET"] as! String
        authURL = infoList["AUTH_URL"] as! String
        appURI = infoList["REDIRECT_URI"] as! String
    }

}
