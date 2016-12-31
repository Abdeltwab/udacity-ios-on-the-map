//
//  PRSStudentData.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 27.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation

struct PRSStudentData {
    
    // basic student meta data
    let firstName: String!
    let lastName: String!
    let latitude: Double!
    let longitude: Double!

    // the URL provided by the student
    let mediaURL: String!
    
    // the location string used for geocoding the student location
    let mapString: String!
    
    // auto-generated id/key generated by Parse which uniquely identifies a StudentLocation
    let objectId: String!
    
    // an extra (optional) key used to uniquely identify a StudentLocation (populate with my udacity account id)
    let uniqueKey: String!
    
    // the fetch date of this structural object
    let evaluationDate: Date!
}