//
//  BaseMapView.swift
//  AssassinVictim
//
//  Created by Mihriban Minaz on 14/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

import Foundation
import MapKit

class BaseMapView: UIView, MKMapViewDelegate {
    weak var mapView: MKMapView?
    var mapNeedsPadding: Bool
    
    override init(frame: CGRect) {
        self.mapNeedsPadding = true
        super.init(frame: frame)
        self.createMap()
        self.setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.mapNeedsPadding = true
        super.init(coder: aDecoder)
        self.createMap()
        self.setNeedsUpdateConstraints()
    }
    
    deinit {
        self.mapView?.delegate = nil
    }
    
    func createMap() {
    
    }
    
    func configureMap(mapView: MKMapView) {
        if self.mapView == nil {
            self.mapView = mapView
            self.mapView!.delegate = self
            self.mapView!.frame = self.bounds
            self.mapNeedsPadding = false
            self.addSubview(self.mapView!)
            self.updateConstraints()
        }
    }
    
    func removeMap() {
        
        if self.mapView != nil {
    self.mapView!.removeAnnotations(self.mapView!.annotations)
        self.mapView!.delegate = nil
        self.mapView!.removeOverlays(self.mapView!.overlays)
        self.mapView!.removeConstraints(self.mapView!.constraints)
        self.mapView!.removeFromSuperview()
        self.mapView = nil
        }
    }
    
    func dictionaryOfNames(arr:UIView...) -> Dictionary<String,UIView> {
        var d = Dictionary<String,UIView>()
        for (ix,v) in arr.enumerate() {
            d["v\(ix+1)"] = v
        }
        return d
    }
    
    override func updateConstraints() {
        if let map = self.mapView where(self.mapView?.superview != nil)
        {
            map.translatesAutoresizingMaskIntoConstraints = false
            let bindings = ["map": map]
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[map]-(0)-|", options: .DirectionLeadingToTrailing, metrics: nil, views: bindings))
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[map]-(0)-|", options: .DirectionLeadingToTrailing, metrics: nil, views: bindings))
        }
        super.updateConstraints()
    }
    
    func zoomToFitMapAnnotations(mapAnnotations: Array<MKAnnotation>?) {
        if mapAnnotations == nil ? true : mapAnnotations!.count <= 0 {
            return
        }
//        
//        var mutableArr = NSMutableArray(array: mapAnnotations!)
//        var userIsNearToResults = false
        
//        if let _ = self.mapView?.userLocation {
//            for theAnnotation in mapAnnotations! {
//                if theAnnotation != self.mapView!.userLocation {
//                    let itemLocation = CLLocation(latitude:theAnnotation.coordinate.latitude, longitude: theAnnotation.coordinate.longitude)
//                    if self.mapView?.userLocation.location?.distanceFromLocation(itemLocation) <= kRouteRangeMax {
//                     userIsNearToResults = true
//                    }
//                }
//            }
//        }
//        if userIsNearToResults == false {
//            mutableArr.removeObject(self.mapView!.userLocation)
//        }
        
        self.mapView?.showAnnotations(mapAnnotations!, animated: true)
    }
    
    func currentZoomLevel() -> Double {
        if let currentSpan = self.mapView?.region.span {
        return currentSpan.latitudeDelta * 0.5 + currentSpan.longitudeDelta * 0.5
        }
        return 0
    }
    
    func markUserLocation(isShown: Bool) {
        self.mapView?.showsUserLocation = isShown
    }
}

