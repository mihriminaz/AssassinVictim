//
//  Gun.swift
//  AssassinVictim
//
//  Created by Mihri on 16/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

import Foundation

@objc public class Gun : PFObject, PFSubclassing {
    @NSManaged public var name : String
    @NSManaged public var damagePoint : Int
    
    override public class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    public class func parseClassName() -> String {
        return "Gun"
    }
    
    internal class func query(key: String) -> PFQuery? {
        let query = PFQuery(className: Gun.parseClassName()) //1
        query.whereKey("objectId", equalTo: "oEaOC5tyPn")
        //query.includeKey("VictimLocation") //2
        query.orderByDescending("createdAt") //3
        return query
    }
    
    override public class func query() -> PFQuery? {
        let query = PFQuery(className: Gun.parseClassName()) //1
        query.whereKey("objectId", equalTo: "oEaOC5tyPn")
        //query.includeKey("VictimLocation") //2
        query.orderByDescending("createdAt") //3
        return query
    }
    
    init(name: String, damagePoint: Int) {
        super.init()
        self.name = name
        self.damagePoint = damagePoint
    }
    
    override init() {
        super.init()
    }
    
}