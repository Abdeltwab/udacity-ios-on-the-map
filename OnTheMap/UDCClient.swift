//
//  UDCClient.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 22.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation

class UDCClient: NSObject {
    
    //
    // MARK: Constants (Statics)
    //
    static let sharedInstance = UDCClient()

    //
    // MARK: Constants (Normal)
    //
    let debugMode: Bool = true
    let session = URLSession.shared
    let client = RequestClient.sharedInstance
    let dateFormatter = DateFormatter()
    
    //
    // MARK: Constants (API)
    //
    let apiURL: String = "https://www.udacity.com/api/session"
    
    //
    // MARK: Variables
    //
    var clientSession: UDCSession? = nil
    
    func getUserSessionDeveloperToken (
        completionHandlerForAuth: @escaping (_ udcSession: UDCSession?, _ error: String?) -> Void) {
    
        let _udcSession = UDCSession(
            accountKey: "9237689572",
            accountRegistered: true,
            sessionId: "1520764715S97349d2a59440130528480c39dfdd1ee",
            sessionExpirationDate: Date() + 2.months - 1.days - 1.minutes,
            created: Date()
        )
        
        completionHandlerForAuth(_udcSession, nil)
    }
    
    /*
     * global method to get udacity userSession by username and password or facebook auth token
     */
    func getUserSessionToken (
         _ username: String?,
         _ password: String?,
         _ fbAuthToken: String?,
           completionHandlerForAuth: @escaping (_ udcSession: UDCSession?, _ error: String?)
        
        -> Void) {
        
        var jsonBodyLogin: [String : AnyObject]?
        
        if let _username = username,
           let _password = password {
        
            jsonBodyLogin = [
                "udacity" : [
                    "username": _username,
                    "password": _password
                ]
            ] as [String : AnyObject]
        }
        
        if let _fbAuthToken = fbAuthToken {
        
            jsonBodyLogin = [
                "facebook_mobile": [
                    "access_token": _fbAuthToken
                ]
            ] as [String : AnyObject]
        }
        
        client.post(apiURL, headers: [:], jsonBody: jsonBodyLogin as [String : AnyObject]?) { (data, error) in
            
            self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            if (error != nil) {
                completionHandlerForAuth(nil, error)
                
            } else {
                
                guard let decodeJsonAccount = data!["account"] as? NSDictionary else {
                    completionHandlerForAuth(nil, "Up's, account key is missing in api response")
                    return
                }
                
                guard let decodeJsonSession = data!["session"] as? NSDictionary else {
                    completionHandlerForAuth(nil, "Up's, session key is missing in api response")
                    return
                }
                
                // create an internal udacity session object and provide this entity to our completion handler
                let _udcSession = UDCSession(
                     accountKey: decodeJsonAccount["key"]! as! String,
                     accountRegistered: decodeJsonAccount["registered"] as? Bool,
                     sessionId: decodeJsonSession["id"] as! String,
                     sessionExpirationDate: self.dateFormatter.date(from: decodeJsonSession["expiration"] as! String),
                     created: Date()
                )
                
                completionHandlerForAuth(_udcSession, nil)
            }
        }
    }
}
