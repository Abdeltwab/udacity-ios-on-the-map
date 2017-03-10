//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 27.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//
import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    //
    // MARK: Constants (Statics)
    //
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //
    // MARK: Constants (Normal)
    //
    let debugMode: Bool = false
    let clientParse = PRSClient.sharedInstance
    let clientUdacity = UDCClient.sharedInstance
    let mapViewLocationManager = MapViewLocationManager.sharedInstance
    
    let locationAccuracy : CLLocationAccuracy = 10 // accuracy factor for device location
    let locationCheckTimeout : TimeInterval = 10   // timeout for device location fetch
    let locationMapZoom : CLLocationDegrees = 10   // zoom factor (0.03 seems best for max zoom)
    let locationDistanceDivider : Double = 1000.0  // rate for metric conversion (m -> km)
    let locationFetchMode : Int8 = 1               // 1: saveMode, 2: quickMode
    
    var locationFetchTrying : Bool = false
    var locationFetchSuccess : Bool = false
    var locationFetchStartTime : Date!
    var locationManager : CLLocationManager { return self.mapViewLocationManager.locationManager }
    var currentLocations = MapViewLocations.sharedInstance.currentLocations
    
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var annotations = [PRSStudentMapAnnotation]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activitySpinner.center = self.view.center
        locationFetchStart()
        updateStudentLocations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager.delegate = self
    }
}
