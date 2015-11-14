//
//  AssassinMapView.swift
//  AssassinVictim
//
//  Created by Mihriban Minaz on 14/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

import Foundation
import MapKit

@objc protocol AssassinMapViewDelegate: class {
    func mapRegionDidChange()
    func userSelectedAVictim(selectedVictim: Victim!)
    func enableThings()
}

class AssassinMapView: BaseMapView {
    var lastSelectedAnnotation : VictimAnnotation?
    weak var delegate: AssassinMapViewDelegate?
    var latestMapItem : MKMapItem?
    
    override func createMap() {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var mapView: MKMapView? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.mapView = MKMapView(frame: self.bounds)
        }
        self.mapView?.userTrackingMode = MKUserTrackingMode.None
        self.configureMap(Static.mapView!)
        self.mapView?.delegate = self
    }
    
    func reloadMap() {
        self.markUserLocation(true)
        //TO DO: do the victim fetch here
        let victims : Array<Victim> = []
        self.reloadPOIsInMap(victims)
    }
    
    func annotationForVictim(victimId:String) -> (VictimAnnotation?) {
        var theAnnotation : VictimAnnotation?
        for annotation in (self.mapView?.annotations)! {
            if let victimAnnotation = annotation as? VictimAnnotation {
                if victimAnnotation.victim.objectId == victimId {
                    theAnnotation = victimAnnotation
                    break
                }
            }
        }
        
        return theAnnotation
    }
    
    func annotationViewForVictim(victimId:String) -> (MKAnnotationView?) {
        var theAnnotationView : MKAnnotationView?
        if let victimAnnotation = annotationForVictim(victimId) {
            self.zoomToFit(victimAnnotation, animated:false)
            if let selectedView = self.mapView?.viewForAnnotation(victimAnnotation) {
                theAnnotationView = selectedView
            }
        }
        
        return theAnnotationView
    }
    
    func selectVictimPOIWithId(victimId:String) {
        if let victimAnnotationView = self.annotationViewForVictim(victimId) as MKAnnotationView! {
            self.showThingsOnMapView(self.mapView!, selectAnnotationView: victimAnnotationView, userManuallySelected: false)
        }
    }
    
    func requestUserLocation(showUserLocation: Bool, animated:Bool) {
        if let userLocation = self.mapView?.userLocation where (showUserLocation == true) {
            if self.mapView?.showsUserLocation ?? true && CLLocationCoordinate2DIsValid(userLocation.coordinate) && userLocation.location != nil {
                self.centerMapInCoordinates(userLocation.coordinate, distance: kDistanceForRegion, animated: animated)
            }
            else {
                self.mapView?.userTrackingMode = .Follow
                self.mapView?.showsUserLocation = true
            }
        }
        else {
            self.mapView?.showsUserLocation = false
        }
        
    }
    
    
    // #pragma mark - Private methods
    
    func reloadPOIsInMap(victims : Array<Victim>?)
    {
        if self.mapView?.annotations.count > 0 {
            self.mapView?.removeAnnotations((self.mapView?.annotations)!)
        }
        if victims?.count > 0 {
            var firstItemSelected = false
            for currentVictim in victims! {
                
                if let location = CLLocationCoordinate2DMake(currentVictim.location.latitude, currentVictim.location.longitude) as CLLocationCoordinate2D! {
                    let annotation = VictimAnnotation(coordinate: location, victim: currentVictim, title: "")
                    
                    if firstItemSelected == false && self.lastSelectedAnnotation == nil {
                        self.lastSelectedAnnotation = annotation
                        firstItemSelected = true
                    }
                    self.mapView?.addAnnotation(annotation)
                }
            }
        }
    }
    
    func maxZoomOfLevelReached() -> Bool {
        return self.currentZoomLevel() > kMaxZoomLevel
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        if self.maxZoomOfLevelReached() == true {
            return
        }
        
        for annotationView in views {
            // Don't pin drop if annotation is user location
            if let _ = annotationView.annotation as? MKUserLocation {
                continue
            }
            
            // Check if current annotation is inside visible map rect, else go to next one
            let point =  MKMapPointForCoordinate(annotationView.annotation!.coordinate)
            if MKMapRectContainsPoint(mapView.visibleMapRect, point) == false
            {
                continue
            }
            
//            if let annotationCoordinates = annotationView.annotation?.coordinate as CLLocationCoordinate2D! {
//                let annotationLocation = CLLocation(latitude: annotationCoordinates.latitude, longitude: annotationCoordinates.longitude)
//                if let mapCenterCoordinates = self.mapView?.centerCoordinate as CLLocationCoordinate2D! {
//                    let mapCenterLocation = CLLocation(latitude: mapCenterCoordinates.latitude, longitude: mapCenterCoordinates.longitude)
            
//                    let distance = annotationLocation.distanceFromLocation(mapCenterLocation)
//                    let mRect = self.mapView!.visibleMapRect
//                    let eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect))
//                    let westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect))
//                    
//                    let mapInMeters = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint)
//                    
                    //And now, bounce!
//                    let durationSteps : UnsafeMutablePointer<CGFloat> = UnsafeMutablePointer<CGFloat>([0.2, 0.2, 0.1])
//                    annotationView.bounceWithDelay(CGFloat(distance/mapInMeters), keysteps: durationSteps)
//                }
//            }
            
        }
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationViewID = "annotationViewID"
        
        var annotationView : MKAnnotationView
        if let anAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationViewID) as MKAnnotationView! {
            anAnnotationView.annotation = annotation
            annotationView = anAnnotationView
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationViewID)
        }
        
        if let _ = annotation as? MKUserLocation {
            annotationView.image = UIImage(named: "pin-around-me")
        }
        else {
            annotationView.image = UIImage(named: "pin-unclicked")
            if let selectedAnnotation = self.lastSelectedAnnotation as VictimAnnotation! {
                if selectedAnnotation == annotation as! VictimAnnotation {
                    annotationView.image = UIImage(named: "pin-clicked")
                }
            }
        }
        
        annotationView.canShowCallout = false
        annotationView.enabled = true
        annotationView.calloutOffset = CGPointMake(-10, 10)
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let anAnnotation = view.annotation as? VictimAnnotation! { //if it is a victim dot
            if anAnnotation != self.lastSelectedAnnotation {
                self.mapView(mapView, didDeSelectAnnotationView: view)
                self.showThingsOnMapView(mapView, selectAnnotationView: view, userManuallySelected: true)
                return
            }
        }
        self.mapView(mapView, didDeSelectAnnotationView: view)
    }
    
    func showThingsOnMapView(mapView:MKMapView, selectAnnotationView:MKAnnotationView, userManuallySelected: Bool) {
        if let victimAnnotation = selectAnnotationView.annotation as? VictimAnnotation {
            for anAnnotation in mapView.annotations {
                if let currentAnnotation = anAnnotation as? VictimAnnotation {
                    if victimAnnotation != currentAnnotation {
                        let previousSelectedView = mapView.viewForAnnotation(anAnnotation)
                        previousSelectedView?.image = UIImage(named: "pin-unclicked")
                    }
                }
            }
            
            UIView.transitionWithView(
                selectAnnotationView,
                duration: 0.2,
                options: .TransitionCrossDissolve,
                animations: { () -> Void in
                    selectAnnotationView.image = UIImage(named: "pin-clicked")
                }, completion: { success in
                    UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: .CurveEaseOut, animations: { () -> Void in
                        selectAnnotationView.transform = CGAffineTransformInvert(CGAffineTransformMakeScale(1.15, 1.15))
                        }, completion: nil)
                }
            )
            
            self.lastSelectedAnnotation = victimAnnotation
            self.mapView?.selectAnnotation(victimAnnotation, animated: true)
            if userManuallySelected == true {
                self.delegate?.userSelectedAVictim(victimAnnotation.victim)
            }
        }
    }
    
    func zoomToFit(annotation: VictimAnnotation, animated: Bool) {
        var allLocations:[CLLocationCoordinate2D] = []
        if let annotationCoordinates = annotation.coordinate as CLLocationCoordinate2D! {
            let annotationLocation = CLLocation(latitude: annotationCoordinates.latitude, longitude: annotationCoordinates.longitude)
            if let distance = self.mapView?.userLocation.location?.distanceFromLocation(annotationLocation) {
                if distance <= kRouteRangeMax {
                    if let locationUser = self.mapView?.userLocation.coordinate as CLLocationCoordinate2D! {
                        allLocations.append(locationUser)
                        allLocations.append(annotation.coordinate)
                        let poly:MKPolygon = MKPolygon(coordinates: &allLocations, count: allLocations.count)
                        self.mapView?.setVisibleMapRect(poly.boundingMapRect, edgePadding: UIEdgeInsetsMake(50.0, 50.0, 100.0, 100.0), animated: animated)
                        return
                    }
                }
            }
            
            if MKMapRectContainsPoint((self.mapView?.visibleMapRect)!, MKMapPointMake(annotationCoordinates.latitude, annotationCoordinates.longitude)) == false {
                self.lastSelectedAnnotation = annotation
                self.mapView?.setCenterCoordinate(annotationCoordinates, animated: animated)
            }
        }
    }
    
    func mapView(mapView: MKMapView, didDeSelectAnnotationView view: MKAnnotationView) {
        view.setSelected(false, animated: true)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if self.maxZoomOfLevelReached() == true {
            if var region = self.mapView?.region {
                // Add a little extra space on the sides
                region.span.latitudeDelta = kMaxZoomLevel * 0.9
                region.span.longitudeDelta = kMaxZoomLevel * 0.9
                self.mapView?.setRegion(region, animated: true)
            }
        }
        else if self.mapNeedsPadding == true {
            self.mapNeedsPadding = false
            self.mapView?.setVisibleMapRect(self.mapView!.visibleMapRect, edgePadding:UIEdgeInsetsMake(50, 50, 100, 100), animated: true)
        }
        self.delegate?.mapRegionDidChange()
    }
    
    func mapView(mapView: MKMapView, didFailToLocateUserWithError error: NSError) {
        if self.mapView?.showsUserLocation == true && self.mapView?.userTrackingMode == .Follow {
          //  UIAlertView.showErrorAlertWithMessage(NSLocalizedString("user_location_error", comment:""))
            self.mapView?.showsUserLocation = false
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if self.mapView?.showsUserLocation == true && self.mapView?.userTrackingMode == .Follow {
            self.mapView?.setCenterCoordinate(userLocation.coordinate, animated: true)
        }
        mapView.setUserTrackingMode(.None, animated: false)
    }
    
    
    func centerMapInCoordinates(coordinates: CLLocationCoordinate2D, distance: Double, animated:Bool) {
        let region = MKCoordinateRegionMakeWithDistance(coordinates, distance, distance)
        self.mapView?.setRegion(region, animated: animated)
    }
    
    func didDeselectAnnotation(annotation:MKAnnotation?) {
        self.mapView?.deselectAnnotation(annotation, animated: true)
    }
    
}
