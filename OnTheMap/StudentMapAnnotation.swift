//
//  StudentMapAnnotation.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 10.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit

class StudentMapAnnotation: UIView {
    
    //
    // MARK: IBOutlet Variables
    //
    
    @IBOutlet weak var studentImage: UIImageView!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var studentMediaURL: UIButton!
    @IBOutlet weak var studentDistance: UILabel!
    @IBOutlet weak var studentGraphDistanceBackground: UILabel!
    @IBOutlet weak var studentGraphDistanceValue: UILabel!
    
    //
    // MARK: IBAction Methods
    //
    
    @IBAction func btnOpenStudentMediaURL(_ sender: Any) {
        
        let app = UIApplication.shared
        
        if var mediaURL = studentMediaURL.title(for: .normal)! as String? {
            
            let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in return }
            let alertController = UIAlertController(
                title: "Alert",
                message: "UP's, unable to open students URL \(mediaURL)! May be this URL is invalid :(",
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            alertController.addAction(btnOkAction)
            
            if (mediaURL.hasPrefix("www")) {
                mediaURL = NSString(format: "https://%@", mediaURL) as String
            }
            
            if validateMediaURL(mediaURL) == true, let nsURL = NSURL(string: mediaURL)  {
                
                if app.canOpenURL(nsURL as URL) == true {
                    app.open(nsURL as URL, options: [:], completionHandler: nil)
                }
                
            } else {
                
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
        
        } else {
        
            studentMediaURL.isEnabled = false
            
        }
    }
    
    //
    // MARK: Private Methods
    //
    
    /*
     * validate string as "linkable" url using quick and lowcost NSTextCheckingResult(link) method
     * return false on any kind of missmatch
     */
    private func validateMediaURL(
        _ urlString: String) -> Bool {
        
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        
        guard (detector != nil && urlString.characters.count > 0) else { return false }
        
        if detector!.numberOfMatches(
            in: urlString,
            options: NSRegularExpression.MatchingOptions(rawValue: 0),
            range: NSMakeRange(0, urlString.characters.count)) > 0 {
            
            return true
        }
        
        return false
    }
}
