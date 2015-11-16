//
//  MainViewController.swift
//  AssassinVictim
//
//  Created by Mihriban Minaz on 14/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

import Foundation
class MainViewController : BaseLoginNeededViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var userTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var playBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.geoLocationChangeListener()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        GeolocationHelper.shared().stopListeningForReference(self)
    }
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        showLoginPage()
    }
    
    @IBAction func userTypeSelected(sender: AnyObject) {
        //TO DO
    }
    
    @IBAction func playTapped(sender: AnyObject) {
        
        if GeolocationHelper.shared().locationServicesAreEnabled() == false {
            if GeolocationHelper.shared().authorizationStatus() == .NotDetermined {
                // 1.1.1 - If we never asked, ask now
                GeolocationHelper.shared().askForLocationServices()
            }
            else {// 1.1.2 - If we asked and user said no, ask him to change his settings
                let askToChangeLocationSettings = UIAlertView(title: NSLocalizedString("Warning", comment:""),
                    message: NSLocalizedString("Please allow the app to access your location first", comment:""),
                    delegate: self,
                    cancelButtonTitle: NSLocalizedString("Cancel", comment:""),
                    otherButtonTitles: NSLocalizedString("OK", comment:""))
                askToChangeLocationSettings.tag = kLocationAlertTag
                askToChangeLocationSettings.show()
            }
        }
        else {
            
            if userTypeSegmentedControl.selectedSegmentIndex == 0 {
                //create assassin
                saveAssassin()
            }
            else if userTypeSegmentedControl.selectedSegmentIndex == 1 {
                //create victim
                saveVictim()
                
            }
        }
    }
    
    func saveAssassin() {
        if let gunQuery = Gun.query("BI4ab8im1D") {//revolver
            
            gunQuery.findObjectsInBackgroundWithBlock { objects, error in
                print("findObjectsInBackgroundWithBlock")
                if error == nil {
                    //2
                    print("findObjectsInBackgroundWithBlock1")
                    if let objects = objects as? [Gun] {
                        print("findObjectsInBackgroundWithBlock2")
                        for gun in objects {
                            //TODO delete if the user was playing as a victim from victim table &|| as a assassin from assassin table
                            
                            if let userLocation = GeolocationHelper.shared().lastKnownPlacemark.location as CLLocation! {
                                PlayerManager.sharedInstance.assassinUser = Assassin(location: PFGeoPoint(location: userLocation), userId: PFUser.currentUser()!, gunId: gun, leftBulletCount: 50)
                                PlayerManager.sharedInstance.assassinUser!.saveInBackgroundWithBlock{ [weak self] success, error in
                                    if success == true {
                                        self?.goToGamePage()
                                    }
                                }
                            }
                            break
                        }
                    }
                } else if let error = error {
                    
                    print("errorerror")
                    print(error)
                    //3
                    // self.showErrorView(error)
                }
            }
        }
    }
    
    func saveVictim() {
        if let userLocation = GeolocationHelper.shared().lastKnownPlacemark.location as CLLocation! {
            //TODO delete if the user was playing as a victim from victim table &|| as a assassin from assassin table
            let victim = Victim(location: PFGeoPoint(location: userLocation), userId: PFUser.currentUser()!, hitPoint: 1000)
            victim.saveInBackgroundWithBlock{ [weak self] success, error in
                if success == true {
                    let alert = UIAlertView(title: NSLocalizedString("Warning", comment:""),
                        message: NSLocalizedString("Playing as a victim is not implemented yet :(", comment:""),
                        delegate: self,
                        cancelButtonTitle: NSLocalizedString("OK", comment:""))
                    alert.show()
                }
            }
        }
        
    }
    
    func goToGamePage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let gameVC = storyboard.instantiateViewControllerWithIdentifier("GameMapViewController") as! GameMapViewController
        self.navigationController?.pushViewController(gameVC, animated: true)
    }
    
    func geoLocationChangeListener() {
        GeolocationHelper.shared().startListeningWithLocationChange(nil, placemarkChange:nil,
            authorizationStatusChange: { [weak self](status: CLAuthorizationStatus) -> Void in
                switch(status) {
                case .NotDetermined, .Restricted, .Denied:
                    self?.playBtn.setTitle("Enable Geolocation", forState: .Normal)
                    break
                case .AuthorizedAlways, .AuthorizedWhenInUse:
                    self?.playBtn.setTitle("PLAY", forState: .Normal)
                    GeolocationHelper.shared().stopListeningForReference(self)
                    break
                }
            }, withReference: self)
    }
}