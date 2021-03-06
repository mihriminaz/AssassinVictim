//
//  BaseLoginNeededViewController.swift
//  AssassinVictim
//
//  Created by Mihriban Minaz on 14/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

import Foundation

class BaseLoginNeededViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (PFUser.currentUser() == nil) {
            showLoginPage()
        }
    }
    
    func showLoginPage() {
        let loginVC : LoginViewController = LoginViewController()
        self.navigationController?.presentViewController(loginVC, animated: true, completion: { () -> Void in
        })
    }
}