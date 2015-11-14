//
//  MainViewController.swift
//  AssassinVictim
//
//  Created by Mihriban Minaz on 14/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

import Foundation
class MainViewController : BaseLoginNeededViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        showLoginPage()
    }
}