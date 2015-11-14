//
//  VictimAnnotation.swift
//  AssassinVictim
//
//  Created by Mihriban Minaz on 14/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

import Foundation
import MapKit

class VictimAnnotation : NSObject, MKAnnotation {
     var victim: Victim
     private var needToShowCallout: Bool = false
     private var _title: String?
     var title: String? {
          return _title
     }
     
     func setTitle(newTitle: String) {
          self._title = newTitle
     }
     
     private var _coordinate: CLLocationCoordinate2D
     var coordinate: CLLocationCoordinate2D {
          return _coordinate
     }
     
     func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
          self._coordinate = newCoordinate
     }
     
     init(coordinate:CLLocationCoordinate2D, victim: Victim, title: String) {
          self.victim = victim
          self._coordinate = coordinate
          self._title = title
          super.init()
     }
     
     static func annotationIdentifier() -> (String) {
          return "VictimListPOI"
     }
}
