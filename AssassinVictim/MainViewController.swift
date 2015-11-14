//
//  MainViewController.swift
//  AssassinVictim
//
//  Created by Mihriban Minaz on 14/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

import Foundation
class MainViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginVC : LoginViewController = LoginViewController()
        self.navigationController?.presentViewController(loginVC, animated: true, completion: { () -> Void in
            
        })
        
    }

}