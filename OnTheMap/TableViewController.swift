//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 27.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//


import UIKit
import BGTableViewRowActionWithImage

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //
    // MARK: IBOutlet variables
    //
    
    @IBOutlet weak var tableView: UITableView!
    
    //
    // MARK: Constants (Normal)
    //
    
    let debugMode: Bool = false
    let clientParse = PRSClient.sharedInstance
    let clientUdacity = UDCClient.sharedInstance
    let cellIdentifier = "studentLocationCell"
    let locationNoData = ""
    let locationCellHeight: CGFloat = 75.0
    
    //
    // MARK: Variables
    //
    
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var locations: [PRSStudentData] { return clientParse.students.locations }
    
    //
    // MARK: UIView Methods (overrides)
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // let views = Bundle.main.loadNibNamed("StudentMapAnnotation", owner: nil, options: nil)
        tableView.register(UINib(nibName: "StudentTableCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView!.reloadData()
        activitySpinner.center = self.view.center
    }
    
    func tableView(
       _ tableView: UITableView,
         numberOfRowsInSection section: Int) -> Int {
        
        return clientParse.students.locations.count
    }
    
    func tableView(
       _ tableView: UITableView,
         cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! StudentTableCell!
        let studentLocationMeta = clientParse.students.locations[indexPath.row]
        
        cell?.lblStudentName.text = NSString(
            format: "%@ %@ %@",
            studentLocationMeta.firstName ?? locationNoData,
            studentLocationMeta.lastName ?? locationNoData,
            studentLocationMeta.flag
        ) as String
        
        cell?.lblStudentMapString.text = NSString(
            format: "%@",
            studentLocationMeta.mapString ?? locationNoData
        ) as String
        
        cell?.lblStudentDistance.text = studentLocationMeta.distance
        
        return cell!
    }
    
    func tableView(
       _ tableView: UITableView,
         heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return self.locationCellHeight;
    }
    
    func tableView(
       _ tableView: UITableView,
         editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let currentCellLocation = self.locations[indexPath.row] as PRSStudentData
        
        // definition for my linkButton using 3rd party lib BGTableViewRowActionWithImage
        let link = BGTableViewRowActionWithImage.rowAction(
            with: UITableViewRowActionStyle.default,
            title: "Profile",
            
            backgroundColor: UIColor(netHex: 0x16A184),
            image: UIImage(named: "icnTableCellProfile_v2"),
            forCellHeight: UInt(self.locationCellHeight)) { action, index in
                
                print (currentCellLocation)
        }
        
        // check if selected row is realy "owned" by current authenticated and show further options
        if currentCellLocation.uniqueKey == clientParse.clientUdacity.clientSession?.accountKey! {

            // definition for my editButton using 3rd party lib BGTableViewRowActionWithImage
            let edit = BGTableViewRowActionWithImage.rowAction(
                with: UITableViewRowActionStyle.default,
                title: " Edit ",
            
                backgroundColor: UIColor(netHex: 0x174881),
                image: UIImage(named: "icnTableCellEdit_v2"),
                forCellHeight: UInt(self.locationCellHeight)) { action, index in
                
                    print (currentCellLocation)
            }
        
            // definition for my deleteButton also using 3rd party lib BGTableViewRowActionWithImage
            let delete = BGTableViewRowActionWithImage.rowAction(
                with: UITableViewRowActionStyle.destructive,
                title: "Delete",
            
                backgroundColor: UIColor(netHex: 0xD30038),
                image: UIImage(named: "icnTableCellDelete_v2"),
                forCellHeight: UInt(self.locationCellHeight)) { action, index in
                
                    print (currentCellLocation)
            }
            
            return [link!, edit!, delete!]
        }
        
        return [link!]
    }
}
