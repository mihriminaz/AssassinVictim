//
//  PlayerManager.swift
//  AssassinVictim
//
//  Created by Mihri on 16/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

import Foundation
class PlayerManager  {
    var assassinUser: Assassin?
   //TODO var victimUser: Victim
    
    class var sharedInstance: PlayerManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: PlayerManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = PlayerManager()
        }
        return Static.instance!
    }
}
