//
//  Assassin.swift
//  AssassinVictim
//
//  Created by Mihriban Minaz on 14/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

import Foundation

@objc public class Assassin : PFObject, PFSubclassing {
    @NSManaged public var leftBulletCount : Int
    @NSManaged public var location : PFGeoPoint
    @NSManaged var userId: PFUser
    @NSManaged var gunId: Gun
    
    override public class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    public class func parseClassName() -> String {
        return "Assassin"
    }
    
    override public class func query() -> PFQuery? {
        let query = PFQuery(className: Assassin.parseClassName()) //1
        //query.includeKey("VictimLocation") //2
        query.orderByDescending("createdAt") //3
        return query
    }
    
    init(location:PFGeoPoint, userId: PFUser, gunId: Gun, leftBulletCount: Int) {
        super.init()
        self.location = location
        self.userId = userId
        self.gunId = gunId
        self.leftBulletCount = leftBulletCount
    }
    
    override init() {
        super.init()
    }
    
}