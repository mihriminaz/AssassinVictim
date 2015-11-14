//
//  GameMapViewController.swift
//  AssassinVictim
//
//  Created by Mihriban Minaz on 14/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class GameMapViewController: BaseLoginNeededViewController, AssassinMapViewDelegate, UIAlertViewDelegate {
    @IBOutlet weak var mapView: AssassinMapView?
    var victimList : NSMutableArray?
    @IBOutlet weak var redoSearchButton: UIButton?
    @IBOutlet weak var relocateMeButton: UIButton?
    var resultsLoading: Bool = false
    let kSearchMaxZoomLevel: Double = 10
    var relocateWhenChanged: Bool = false
    var firstLoad: Bool = true
    
    // MARK: - Life Cycle methods
    func removeThingsBeforePop() {
        if let mkMapView = self.mapView?.mapView {
            self.mapView?.centerMapInCoordinates(mkMapView.centerCoordinate, distance: kDistanceForRegion, animated:false)
            if mkMapView.selectedAnnotations.count > 0 {
                if let annotation = mkMapView.selectedAnnotations.last {
                    mkMapView.deselectAnnotation(annotation, animated: false)
                }
            }
        }
        
        GeolocationHelper.shared().stopListeningForReference(self)
        self.mapView?.delegate = nil
        self.mapView?.lastSelectedAnnotation = nil
    }
    
    func prepareForOpenWithReload() {
        if self.firstLoad == false {
            self.reloadMapData()
        }
        else {
            self.mapView?.zoomToFitMapAnnotations(self.mapView?.mapView?.annotations)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageVisuals()
        self.mapView?.createMap()
        self.mapView?.delegate = self
        self.geoLocationChangeListener()
        self.redoSearch()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView?.delegate = self
        prepareForOpenWithReload()
        self.relocateMeButton?.setImage(GeolocationHelper.shared().locationServicesAreEnabled() ? UIImage(named: "around-me") : UIImage(named: "around-me-disabled"), forState: .Normal)
        
        if self.firstLoad == true {
            self.reloadMapData()
        }
        self.firstLoad = false
        
        let delay = 3.0 * Double(NSEC_PER_SEC)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay)), dispatch_get_main_queue()) { [weak self]() -> Void in
            if self?.victimList?.count > 0 {
                self?.mapView?.reloadMap((self?.victimList!)!)
            }
        }

        
       
    }
    
    func pageVisuals() {
        self.view.clipsToBounds = true
    }
    
    // MARK: - Private methods
    
    func reloadMapData() {
        
        self.mapView?.zoomToFitMapAnnotations(self.mapView?.mapView?.annotations)
        if let selectedAnnotation = self.mapView?.lastSelectedAnnotation {
            self.mapView?.mapView?.selectAnnotation(selectedAnnotation, animated: false)
        }
    }
    
    func reloadPageWithData(){
        self.mapView?.lastSelectedAnnotation = nil
        self.reloadMapData()
    }
    
    
    func victimWasTapped(victim: Victim) {
        
    }
    
    func mapRegionDidChange() {
        self.redoSearchButton?.enabled = true
    }
    
    func userSelectedAVictim(selectedVictim: Victim!) {
        //scroll to the item in the list
        
//        if let _ = victimList.indexOfObject(selectedVictim)
//        {
//            
//        }
    }
    
    func userInteractionEnabled(isEnabled:Bool){
        self.mapView?.userInteractionEnabled = isEnabled
        self.relocateMeButton?.userInteractionEnabled = isEnabled
        self.redoSearchButton?.userInteractionEnabled = isEnabled
    }
    
    @IBAction func redoSearchButtonPressed(sender: UIButton) {
    }
    func redoSearch(){
        print("redoSearch")
        if self.resultsLoading == false {
//            if self.mapView?.currentZoomLevel() > kSearchMaxZoomLevel {
//                // self.showErrorAlertWithMessage(NSLocalizedString("You’re way too far! Zoom in and search again.", comment:""))
//            }
//            else {
                self.resultsLoading = true
                
                self.victimList = NSMutableArray()
                
                let query = Victim.query()!
                query.findObjectsInBackgroundWithBlock { objects, error in
                    
                    print("findObjectsInBackgroundWithBlock")
                    if error == nil {
                        //2
                        print("findObjectsInBackgroundWithBlock1")
                        if let objects = objects as? [Victim] {
                            print("findObjectsInBackgroundWithBlock2")
                            self.victimList = NSMutableArray(array: objects)
                           self.mapView?.reloadMap(self.victimList!)
                        }
                    } else if let error = error {
                        
                        print("errorerror")
                        print(error)
                        //3
                       // self.showErrorView(error)
                    }
                    
                    self.resultsLoading = false
                }
                
            }
        //}
    }
    
    @IBAction func relocateMeButtonPressed(sender: UIButton) {
        if GeolocationHelper.shared().locationServicesAreEnabled() == false {
            if GeolocationHelper.shared().authorizationStatus() == .NotDetermined {
                // 1.1.1 - If we never asked, ask now
                self.relocateWhenChanged = true
                GeolocationHelper.shared().askForLocationServices()
            }
            else {// 1.1.2 - If we asked and user said no, ask him to change his settings
                let askToChangeLocationSettings = UIAlertView(title: NSLocalizedString("Warning", comment:""),
                    message: NSLocalizedString("Please allow the app to access your location first", comment:""),
                    delegate: self,
                    cancelButtonTitle: NSLocalizedString("Abbrechen", comment:""),
                    otherButtonTitles: NSLocalizedString("OK", comment:""))
                askToChangeLocationSettings.tag = kLocationAlertTag
                askToChangeLocationSettings.show()
            }
        }
        else {
            
            self.mapView?.requestUserLocation(true, animated:false)
            let delay = 2.0 * Double(NSEC_PER_SEC)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay)), dispatch_get_main_queue()) { [weak self]() -> Void in
                self?.reloadMapData()
            }
        }
    }
    func enableThings() {
        
    }
    
    func geoLocationChangeListener() {
        GeolocationHelper.shared().startListeningWithLocationChange(nil, placemarkChange:nil,
            authorizationStatusChange: { [weak self](status: CLAuthorizationStatus) -> Void in
                switch(status) {
                case .NotDetermined, .Restricted, .Denied:
                    self?.relocateMeButton?.setImage(UIImage(named: "around-me-disabled"), forState: .Normal)
                    self?.relocateWhenChanged = false
                    break
                case .AuthorizedAlways, .AuthorizedWhenInUse:
                    self?.relocateMeButton?.setImage(UIImage(named: "around-me"), forState: .Normal)
                    if self?.relocateWhenChanged == true {
                        self?.relocateMeButtonPressed((self?.relocateMeButton)!)
                        self?.relocateWhenChanged = false
                    }
                    break
                }
                
            }, withReference: self)
    }
    
    @IBAction func exitButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
}