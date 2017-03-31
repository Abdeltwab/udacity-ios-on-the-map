//
//  GClientCache.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 31.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import Foundation

class GClientCache {

    static let sharedInstance = GClientCache()
    
    var metaData = [GClientSession]()
    
    func clearCache() {
    
        metaData.removeAll()
    }
}
