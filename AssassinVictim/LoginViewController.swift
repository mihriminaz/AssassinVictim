//
//  LoginViewController.swift
//  AssassinVictim
//
//  Created by Mihriban Minaz on 14/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

import UIKit
import ParseUI

class LoginViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       if (PFUser.currentUser() == nil) {
            let loginViewController = PFLogInViewController()
            loginViewController.delegate = self
   
            let imageView = UIImageView(image: UIImage(named: "Assassin"))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
            loginViewController.logInView?.logo = imageView
            
            loginViewController.title = "Assassin vs Victim"
            loginViewController.fields = PFLogInFields(rawValue:
                PFLogInFields.UsernameAndPassword.rawValue |
                    PFLogInFields.LogInButton.rawValue |
                    PFLogInFields.PasswordForgotten.rawValue |
                PFLogInFields.SignUpButton.rawValue | PFLogInFields.Facebook.rawValue)

            loginViewController.emailAsUsername = true
        loginViewController.signUpController?.delegate = self
        
        let imageView2 = UIImageView(image: UIImage(named: "Assassin"))
        loginViewController.signUpController?.signUpView?.logo = imageView2
        
            self.presentViewController(loginViewController, animated: false, completion: nil)
        } else {
            presentLoggedInAlert()
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
        presentLoggedInAlert()
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
        presentLoggedInAlert()
    }
    
    func presentLoggedInAlert() {
        self.dismissViewControllerAnimated(true, completion: nil)
//        let alertController = UIAlertController(title: "You're logged in", message: "Welcome to Assassin!", preferredStyle: .Alert)
//        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }
//        alertController.addAction(OKAction)
//        self.presentViewController(alertController, animated: true, completion: nil)
    }
}


