//
//  MapViewControllerExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 09.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit
import MapKit
import YNDropDownMenu

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    //
    // MARK: Class internal methods
    //
    
    /*
     * update a specific user location from map annotation panel directly (not used yet)
     */
    func userLocationUpdate(
       _ userLocation: PRSStudentData!) {
    
        self.clientParse.updateStudentLocation(userLocation) {
            
            (success, error) in
            
            if success == true {
                
                OperationQueue.main.addOperation { self.updateStudentLocations() }
                
            } else {
                
                // client error updating location? show corresponding message and return ...
                let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in return }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(btnOkAction)
                OperationQueue.main.addOperation {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    /*
     * action wrapper for update userLocation using button click call from annotation directly
     * try to fetch object by given object id and set it as appDelegate.currentUserStudentLocation
     * after that call method userLocationAdd(_ editMode = true)
     */
    func userLocationEditProfileAction(
       _ sender: UIButton) {
    
        let objectId = sender.accessibilityHint
        
        if objectId != nil && objectId?.isEmpty == false {
            
            if let userLocation: PRSStudentData = getOwndedStudentLocationByObjectId(objectId!) {
                
                appDelegate.currentUserStudentLocation = userLocation
                userLocationAdd( true )
                
            } else {
                
                let locationNotFoundWarning = UIAlertController(
                    title: "Location Warning ...",
                    message: "Location with objectId \(String(describing: objectId)) not found!",
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                let dlgBtnCancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) in
                    return
                }
                
                locationNotFoundWarning.addAction(dlgBtnCancelAction)
                
                self.present(locationNotFoundWarning, animated: true, completion: nil)
            }
        }
    }
    
    /*
     * action wrapper for delete userLocation using button click call from annotation directly
     */
    func userLocationDeleteAction(
       _ sender: UIButton) {
        
        // using accessibilityHint "hack" to fetch a specific id (here objectId of parse.com)
        let objectId = sender.accessibilityHint
        
        if objectId != nil && objectId?.isEmpty == false {
        
            let locationDestructionWarning = UIAlertController(
                title: "Removal Warning ...",
                message: "Do you really want to delete this location?",
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            let dlgBtnYesAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction!) in
                // execute api call to delete user location object
                self.userLocationDelete(objectId!)
            }
            
            let dlgBtnCancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) in
                return
            }
            
            locationDestructionWarning.addAction(dlgBtnYesAction)
            locationDestructionWarning.addAction(dlgBtnCancelAction)
            
            self.present(locationDestructionWarning, animated: true, completion: nil)
        }
    }
    
    /*
     * delete a specific userLocation from parse api persitence layer
     */
    func userLocationDelete(
       _ userLocationObjectId: String!) {
        
        self.clientParse.deleteStudentLocation (userLocationObjectId) {
            
            (success, error) in
            
            if success == true {
                
                // remove object id from all corresponding collections
                self.clientParse.students.removeByObjectId(userLocationObjectId)
                
                // update locations stack *** not required if lists are cleared natively
                OperationQueue.main.addOperation { self.updateStudentLocations() }
                
            } else {
                
                // client error deleting location? show corresponding message and return ...
                let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in return }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(btnOkAction)
                OperationQueue.main.addOperation {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    /*
     * this method will delete all userLocations (studenLocations) from parse api persitence layer
     */
    func userLocationDeleteAll() {
        
        for location in clientParse.students.myLocations {
            self.userLocationDelete(location.objectId)
        }
    }
    
    /*
     * this method will add a new or update an existing userLocation from parse api persistence layer
     */
    func userLocationAdd(_ editMode: Bool) {
        
        appDelegate.inEditMode = editMode
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PageSetRoot") as! LocationEditViewController
        let locationRequestController = UIAlertController(
            title: "Let's start ...",
            message: "Do you want to use your current device location as default for your next steps?",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        
        let dlgBtnYesAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction!) in
            // check device location again ...
            self.updateDeviceLocation()
            // useCurrentDeviceLocation: true means our pageViewController will use a smaller stack of pageSetControllers
            self.appDelegate.useCurrentDeviceLocation = true
            // check if last location doesn't match the current one ... if app in create mode only
            if editMode == false && self.validateCurrentLocationAgainstLastPersistedOne() == false {
                
                let locationDuplicateWarningController = UIAlertController(
                    title: "Duplication Warning ...",
                    message: "Your current device location is already in use by one of your previous locations!\n" +
                    "You can ignore this but you'll add a location duplicate doing this!",
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                let dlgBtnIgnoreWarningAction = UIAlertAction(title: "Ignore", style: .default) { (action: UIAlertAction!) in
                    self.present(vc, animated: true, completion: nil)
                }
                
                let dlgBtnCancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) in
                    return
                }
                
                locationDuplicateWarningController.addAction(dlgBtnIgnoreWarningAction)
                locationDuplicateWarningController.addAction(dlgBtnCancelAction)
                
                self.present(locationDuplicateWarningController, animated: true, completion: nil)
                
            } else {
                
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        let dlgBtnNoAction = UIAlertAction(title: "No", style: .default) { (action: UIAlertAction!) in
            
            // useCurrentDeviceLocation: false means our pageViewController will use the full stack of pageSetControllers
            self.appDelegate.useCurrentDeviceLocation = false
            self.present(vc, animated: true, completion: nil)
        }
        
        locationRequestController.addAction(dlgBtnYesAction)
        locationRequestController.addAction(dlgBtnNoAction)
        
        present(locationRequestController, animated: true, completion: nil)
    }

    /*
     * this method will handle the 3 cases of user location persitence/validations
     */
    func handleUserLocation() {
        
        let dlgBtnCancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) in
            return }
        
        let dlgBtnDeleteAction = UIAlertAction(title: "Delete", style: .default) { (action: UIAlertAction!) in
            self.userLocationDeleteAll() }
        
        let dlgBtnAddLocationAction = UIAlertAction(title: "Add", style: .default) { (action: UIAlertAction!) in
            self.userLocationAdd( false ) }
        
        let dlgBtnUpdateAction = UIAlertAction(title: "Update", style: .default) { (action: UIAlertAction!) in
            self.userLocationAdd( true ) }
        
        let alertController = UIAlertController(title: "Warning", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(dlgBtnDeleteAction)
        alertController.message = "You've already set your student location, do you want to delete or update the last one?"
        if self.clientParse.metaMyLocationsCount! > 1 {
            alertController.message = NSString(
                format: "You've already set your student location, do you want to delete the %d old locations?",
                self.clientParse.metaMyLocationsCount!) as String!
        }
        
        switch true {
            
            // no locations found, load addLocation formular
            case self.clientParse.metaMyLocationsCount! == 0: self.userLocationAdd( false ); break
            // moultiple locations found, let user choose between delete all or update the last persited location
            case self.clientParse.metaMyLocationsCount! > 0:
            
                alertController.addAction(dlgBtnAddLocationAction)
                alertController.addAction(dlgBtnUpdateAction)
                alertController.addAction(dlgBtnCancelAction)
            
                self.appDelegate.currentUserStudentLocation = self.clientParse.students.myLocations.last
                
                OperationQueue.main.addOperation { self.present(alertController, animated: true, completion: nil) }
            
                break
            
            default: break
        }
    }
    
    /*
     * simple wrapper for fetchAll student locations call, used during map initialization and by updateButton process call
     */
    func updateStudentLocations () {
        
        mapView.removeAnnotations(annotations)
        fetchAllStudentLocations()
    }
    
    /*
     * load all available student locations and handle api error result if parse call won't be succesfully
     */
    func fetchAllStudentLocations () {
        
        // deactivate and remove activity spinner
        self.activitySpinner.stopAnimating()
        self.view.willRemoveSubview(self.activitySpinner)
        
        clientParse.getAllStudentLocations () {
            
            (success, error) in
            
            if success == true {
                
                self.generateMapAnnotationsArray()
                
            } else {
                
                // error? do something ... but for now just clean up the alert dialog
                let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(btnOkAction)
                OperationQueue.main.addOperation { self.present(alertController, animated: true, completion:nil) }
            }
            
            // deactivate and remove activity spinner
            self.activitySpinner.stopAnimating()
            self.view.willRemoveSubview(self.activitySpinner)
        }
    }
    
    /*
     * generate the student meta based map annoation array, render results by async queue transfer to mapView directly
     * and manipulate/enrich the origin location by further (calculated) meta-data (currently the device distance to
     * other students)
     */
    func generateMapAnnotationsArray () {
        
        let students = PRSStudentLocations.sharedInstance
        
        var renderDistance: Bool = false
        var sourceLocation: CLLocation?
        var targetLocation: CLLocation?
        var currentDeviceLocation: DeviceLocation?
        
        // remove all old annotations
        annotations.removeAll()
        
        // render distance to other students only if device location meta data available
        if appDelegate.currentDeviceLocations.count > 0 {
            currentDeviceLocation = appDelegate.currentDeviceLocations.first
            sourceLocation = CLLocation(
                latitude: (currentDeviceLocation?.latitude)!,
                longitude: (currentDeviceLocation?.longitude)!
            )
            
            renderDistance = true
        }
        
        for (index, dictionary) in students.locations.enumerated() {
            
            let coordinate = CLLocationCoordinate2D(latitude: dictionary.latitude!, longitude: dictionary.longitude!)
            let annotation = PRSStudentMapAnnotation(coordinate)
            
            annotation.objectId = dictionary.objectId
            annotation.url = dictionary.mediaURL ?? locationNoData
            annotation.subtitle = annotation.url ?? locationNoData
            annotation.title = NSString(
                format: "%@ %@",
                dictionary.firstName ?? locationNoData,
                dictionary.lastName ?? locationNoData) as String
            
            if renderDistance {
                targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                annotation.distance = getPrintableDistanceBetween(sourceLocation, targetLocation)
                students.locations[index].distance = annotation.distance!
            }
            
            if dictionary.uniqueKey == clientParse.clientUdacity.clientSession?.accountKey! {
                annotation.ownLocation = true
            }
            
            annotations.append(annotation)
        }
        
        DispatchQueue.main.async { self.mapView.addAnnotations(self.annotations) }
    }
    
    /*
     * get the printable (human readable) distance between two locations (using fix metric system)
     */
    func getPrintableDistanceBetween(
       _ sourceLocation: CLLocation!,
       _ targetLocation: CLLocation!) -> String {
        
        let distanceValue = sourceLocation.distance(from: targetLocation)
        
        // todo(!) should be handle by localization manager instead using static metric definition here
        var distanceOut: String! = NSString(format: "%.0f %@", distanceValue, "m") as String
        if distanceValue >= locationDistanceDivider {
            distanceOut = NSString(format: "%.0f %@", (distanceValue / locationDistanceDivider), "km") as String
        }
        
        return distanceOut
    }
    
    /*
     * get a owned student location by their corresponding objectId
     */
    func getOwndedStudentLocationByObjectId(
       _ objectId: String) -> PRSStudentData? {
        
        for location in clientParse.students.myLocations {
            if location.objectId == objectId {
                return location
            }
        }
        
        return nil
    }
    
    /*
     * check current device location against the last persisted studentLocation meta information.
     * If both locations seems to be "plausible equal" this validation method will be returned false.
     * For accuracy reasons I'll round the coordinates down to 6 decimal places (:locationCoordRound)
     */
    func validateCurrentLocationAgainstLastPersistedOne() -> Bool {
        
        let lastDeviceLocation = appDelegate.currentDeviceLocations.last
        let lastStudentLocation = clientParse.students.myLocations.last
        
        // no local studen location for my account found? fine ...
        if lastStudentLocation == nil {
            return true
        }
        
        let _lastDeviceLongitude: Double = lastDeviceLocation!.longitude!.roundTo(locationCoordRound)
        let _lastDeviceLatitude: Double = lastDeviceLocation!.latitude!.roundTo(locationCoordRound)
        let _lastUserStudentLongitude: Double = lastStudentLocation!.longitude!.roundTo(locationCoordRound)
        let _lastUserStudentLatitude: Double = lastStudentLocation!.latitude!.roundTo(locationCoordRound)
        
        if _lastDeviceLongitude == _lastUserStudentLongitude &&
           _lastDeviceLatitude  == _lastUserStudentLatitude {
            
            return false
        }
        
        return true
    }
    
    /*
     * update location meta information and (re)positioning current mapView
     */
    func updateCurrentLocationMeta(
       _ coordinate: CLLocationCoordinate2D) {
        
        let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let currentDeviceLocation : NSDictionary = [ "latitude": coordinate.latitude, "longitude": coordinate.longitude ]
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: locationMapZoom, longitudeDelta: locationMapZoom)
        )
        
        appDelegate.currentDeviceLocations.removeAll() // currently we won't persist all evaluated device locations
        appDelegate.currentDeviceLocations.append(DeviceLocation(currentDeviceLocation)) // persist device location
        appDelegate.useCurrentDeviceLocation = true
        appDelegate.useLongitude = coordinate.longitude
        appDelegate.useLatitude = coordinate.latitude
        
        locationFetchSuccess = true
        
        mapView.setRegion(region, animated: true)
        
        if debugMode == true {
            print("-------------------------------------------------------------")
            print("You are at [\(coordinate.latitude)] [\(coordinate.longitude)]")
            print("-------------------------------------------------------------")
        }
    }
    
    /*
     * start location scan
     */
    func updateDeviceLocation() {
        
        deviceLocationManager.checkForLocationAccess {
            
            switch self.locationFetchMode
            {
                case 1:
                
                    if self.locationFetchTrying { return }
                
                    self.locationFetchTrying = true
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    self.locationManager.activityType = .fitness
                    self.locationManager.distanceFilter = self.locationDistanceHook
                    self.locationFetchStartTime = nil
                
                    self.locationManager.startUpdatingLocation()
                
                case 2:
                
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    self.locationManager.requestLocation()
                
                default: break
            }
        }
    }
    
    /*
     * stop location scan
     */
    func locationFetchStop () {
        
        locationManager.stopUpdatingLocation()
        locationFetchStartTime = nil
        locationFetchTrying = false
    }
    
    /*
     * handle add user location (delegatable) method call
     */
    func _callAddUserLocationAction() {
        
        clientParse.getMyStudentLocations() { (success, error) in
            
            if success == true {
                
                self.handleUserLocation()
                
            } else {
                
                let alertController = UIAlertController(title: "Alert", message: error, preferredStyle: UIAlertControllerStyle.alert)
                let Action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in }
                
                alertController.addAction(Action)
                OperationQueue.main.addOperation {
                    self.present(alertController, animated: true, completion:nil)
                }
            }
        }
    }
    
    /*
     * logout facebook authenticated user
     */
    func _callLogOutFacebookAction() {
    
            clientFacebook.removeUserSessionTokenAndLogOut {
            
            (success, error) in
            
            if success == true {
                
                self._callLogOutSystemAction()
                
            } else {
                
                // client error updating location? show corresponding message and return ...
                let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in return }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(btnOkAction)
                OperationQueue.main.addOperation {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    /*
     * logout udacity authenticated user
     */
    func _callLogOutUdacityAction() {
    
        clientUdacity.removeUserSessionTokenAndLogOut {
            
            (success, error) in
            
            if success == true {
                
                self._callLogOutSystemAction()
                
            } else {
                
                // client error updating location? show corresponding message and return ...
                let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in return }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(btnOkAction)
                OperationQueue.main.addOperation {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    /*
     * (finalize) system logout, cleanUp all local persited session data
     */
    func _callLogOutSystemAction() {
    
        self.appDelegate.currentUserStudentLocation = nil
        self.clientFacebook.clientSession = nil
        self.clientUdacity.clientSession = nil
        
        self.dismiss( animated: true )
    }
    
    /*
     * handle logout user (delegatable) method call for udacity and fb sessions
     */
    func _callLogOutAction() {
    
        // kill all running background / asynch operations
        if debugMode { print (" <logout> cancel all operations") }
        OperationQueue.main.cancelAllOperations()
        appDelegate.forceQueueExit = true
        
        if appDelegate.isAuthByFacebook == true {
            
            if debugMode { print (" <logout> execute facebook logout") }
           _callLogOutFacebookAction()
            
        } else if appDelegate.isAuthByUdacity == true {
            
            if debugMode { print (" <logout> execute udacity logout") }
           _callLogOutUdacityAction()
            
        } else {
            
            if debugMode { print (" <logout> execute fallback system logout") }
           _callLogOutSystemAction()

        }
    }
    
    /*
     * handle reload map (delegatable) method call
     */
    func _callReloadMapAction() {
        
        updateStudentLocations()
        updateDeviceLocation()
    }
    
    /*
     * handle delegate commands from other view (e.g. menu calls)
     */
    func handleDelegateCommand(
        _ command: String) {
        
        if debugMode == true { print ("_received command: \(command)") }
        
        if command == "addUserLocationFromMenu" {
            appMenu!.hideMenu()
           _callAddUserLocationAction()
        }
        
        if command == "reloadUserLocationMapFromMenu" {
            appMenu!.hideMenu()
           _callReloadMapAction()
        }
        
        if command == "logOutUserFromMenu" {
            appMenu!.hideMenu()
           _callLogOutAction()
        }
    }
    
    func initMenu() {
        
        let menuViews = Bundle.main.loadNibNamed("StudentMapMenu", owner: nil, options: nil) as? [StudentMapMenu]
        
        if let _menuViews = menuViews {
            
            // take first view definition as studentMapMenu and activate command delegation pipe
            let backgroundView = UIView()
            let _menuView = _menuViews[0] as StudentMapMenu
                _menuView.delegate = self
            
            appMenu = YNDropDownMenu(
                frame: CGRect(x: 0, y: 28, width: UIScreen.main.bounds.size.width, height: 38),
                dropDownViews: [_menuView],
                dropDownViewTitles: [""] // no title(s) required
            )
            
            appMenu!.setImageWhen(
                normal: UIImage(named: "icnMenu_v1"),
                selected: UIImage(named: "icnCancel_v1"),
                disabled: UIImage(named: "icnMenu_v1")
            )
            
            appMenu!.setLabelColorWhen(normal: .black, selected: UIColor(netHex: 0xFFA409), disabled: .gray)
            appMenu!.setLabelFontWhen(normal: .systemFont(ofSize: 12), selected: .boldSystemFont(ofSize: 12), disabled: .systemFont(ofSize: 12))
            appMenu!.backgroundBlurEnabled = true
            appMenu!.bottomLine.isHidden = false
            
            backgroundView.backgroundColor = .black
            appMenu!.blurEffectView = backgroundView
            appMenu!.blurEffectViewAlpha = 0.7
            appMenu!.alwaysSelected(at: 0)
            
            self.view.addSubview(appMenu!)
        }
    }
    
    //
    // MARK: Delegates
    //
    
    /*
     * handle authorization change for location fetch permission using corresponding delegate call of locationManager
     */
    func locationManager(
       _ manager: CLLocationManager,
         didChangeAuthorization status: CLAuthorizationStatus) {
        
        if debugMode { print("locationManager: permission/authorization mode changed -> \(status.rawValue)") }
        
        switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                deviceLocationManager.doThisWhenAuthorized?()
                deviceLocationManager.doThisWhenAuthorized = nil
            
            default: break
        }
    }
    
    /*
     * error handling of location fetch using corresponding delegate call of locationManager
     */
    func locationManager(
       _ manager: CLLocationManager,
         didFailWithError error: Error) {
        
        if debugMode { print("locationManager: localization request finally failed -> \(error)") }
        
        locationFetchSuccess = false
        locationFetchStop()
    }
    
    /*
     * fetch current device location using corresponding delegate call of locationManager
     */
    func locationManager(
       _ manager: CLLocationManager,
         didUpdateLocations locations: [CLLocation]) {
        
        let _location = locations.last!
        let _coordinate = _location.coordinate
        
        switch locationFetchMode
        {
            case 1:
            
                let _accuracy = _location.horizontalAccuracy
                let _determinationTime = _location.timestamp
            
                // ignore first attempt
                if locationFetchStartTime == nil {
                    locationFetchStartTime = Date()
                    
                    return
                }
            
                // ignore overtime requests
                if _determinationTime.timeIntervalSince(self.locationFetchStartTime) > locationCheckTimeout {
                    locationFetchStop()
                
                    return
                }
                
                // wait for the next one
                if _accuracy < 0 || _accuracy > locationAccuracy { return }
            
                locationFetchStop()
                updateCurrentLocationMeta(_coordinate)
            
            case 2:
                
                updateCurrentLocationMeta(_coordinate)
            
            default: break
        }
    }
    
    func mapView(
       _ mapView: MKMapView,
         didUpdate userLocation: MKUserLocation) {
        
        updateCurrentLocationMeta(mapView.userLocation.coordinate)
    }
    
    func mapView(
       _ mapView: MKMapView,
         viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is PRSStudentMapAnnotation) { return nil }
        
        let identifier = "locPin_0"
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            
            annotationView = StudentMapAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
            
        } else {
            
            annotationView?.annotation = annotation
            
        }
        
        annotationView?.image = UIImage(named: "icnUserDefault_v1")
        
        return annotationView
    }
    
    func mapView(
       _ mapView: MKMapView,
         didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation { return }
        
        let studentAnnotation = view.annotation as! PRSStudentMapAnnotation
        let views = Bundle.main.loadNibNamed("StudentMapAnnotation", owner: nil, options: nil)
        let calloutView = views?[0] as! StudentMapAnnotation
        
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height * 0.65)
        calloutView.studentName.text = studentAnnotation.title
        calloutView.studentMediaURL.setTitle(studentAnnotation.url, for: .normal)
        if studentAnnotation.distance != nil {
            calloutView.studentDistance.text = studentAnnotation.distance
        }
        
        calloutView.studentImage.image = UIImage(named: "imgUserDefault_v2")
        if studentAnnotation.ownLocation == true {
            calloutView.studentImage.image = UIImage(named: "icnUserSampleBig_v1")
            
            let btnDeleteImage = UIImage(named: "icnDelete_v1") as UIImage?
            let btnDelete = UIButton(type: UIButtonType.custom) as UIButton
            
            let btnEditImage = UIImage(named: "icnEditProfile_v1") as UIImage?
            let btnEdit = UIButton(type: UIButtonType.custom) as UIButton
            
            btnDelete.frame = CGRect(x: 108, y: 65, width: 25, height: 25)
            btnDelete.setImage(btnDeleteImage, for: .normal)
            btnDelete.accessibilityHint = studentAnnotation.objectId
            btnDelete.addTarget(self, action: #selector(MapViewController.userLocationDeleteAction(_:)), for: .touchUpInside)
            
            btnEdit.frame = CGRect(x: 143, y: 65, width: 25, height: 25)
            btnEdit.setImage(btnEditImage, for: .normal)
            btnEdit.accessibilityHint = studentAnnotation.objectId
            btnEdit.addTarget(self, action: #selector(MapViewController.userLocationEditProfileAction(_:)), for: .touchUpInside)
            
            calloutView.addSubview(btnDelete)
            calloutView.addSubview(btnEdit)
        }
        
        view.addSubview(calloutView)
        
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    func mapView(
       _ mapView: MKMapView,
         didDeselect view: MKAnnotationView) {
        
        if view.isKind(of: StudentMapAnnotationView.self) {
            for subview in view.subviews {
                subview.removeFromSuperview()
            }
        }
    }
}
