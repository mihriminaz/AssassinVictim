//
//  Victim.swift
//  AssassinVictim
//
//  Created by Mihriban Minaz on 14/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

import Foundation

class Victim : NSObject {
    var objectId: String
    var coordinates : CLLocationCoordinate2D
    init(coordinates:CLLocationCoordinate2D, objectId: String) {
        self.coordinates = coordinates
        self.objectId = objectId
        super.init()
    }
}