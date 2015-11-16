//
//  VictimDetailViewController.swift
//  AssassinVictim
//
//  Created by Mihri on 16/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

import Foundation

class VictimDetailViewController : BaseLoginNeededViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var pointLbl: UILabel!
    @IBOutlet weak var hitLeft: UILabel!
    @IBOutlet weak var shootBtn: UIButton!
    var victim : Victim?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let aVictim = victim {
        self.hitLeft.text = String(format:"%ld", aVictim.hitPoint)
        self.pointLbl.text = "If you kill you will get " + String(format:"%ld", aVictim.hitPoint) + " points!"
        }
    }
    
    @IBAction func shootTapped(sender: AnyObject) {
        
        if let aVictim = victim where (PlayerManager.sharedInstance.assassinUser != nil) {
        let victimLocation = CLLocationCoordinate2DMake(aVictim.location.latitude, aVictim.location.longitude)
        if GeolocationHelper.shared().distanceInMetersFrom(victimLocation) > 100000 {
            //if victim is 100 meters away you can not shoot
            
            let alert = UIAlertView(title: NSLocalizedString("Get closer", comment:""),
                message: NSLocalizedString("Victim is far away, go there!", comment:""),
                delegate: self,
                cancelButtonTitle: NSLocalizedString("OK", comment:""))
            alert.show()
        }
        else {
            //shoot
            aVictim.hitPoint -= PlayerManager.sharedInstance.assassinUser!.gunId.damagePoint
            
          self.shootBtn.enabled = false
            if aVictim.hitPoint < 0 {
                aVictim.hitPoint = 0
                self.shootBtn.enabled = false
                let alert = UIAlertView(title: NSLocalizedString("Mission Accomplished", comment:""),
                    message: NSLocalizedString("Don't shoot for more the guy is dead :(yani vurayin adam oldu)", comment:""),
                    delegate: self,
                    cancelButtonTitle: NSLocalizedString("OK", comment:""))
                alert.show()
            }
            }
            aVictim.saveInBackgroundWithBlock{ [weak self] success, error in
                self?.hitLeft.text = String(format:"%ld", aVictim.hitPoint)
                self?.shootBtn.enabled = true
            }
        }
    }
}