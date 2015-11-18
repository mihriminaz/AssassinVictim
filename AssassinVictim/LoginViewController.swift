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
                   PFLogInFields.SignUpButton.rawValue
                    | PFLogInFields.Facebook.rawValue
        )

        loginViewController.logInView?.facebookButton?.addTarget(self, action:"fbLoginClick", forControlEvents: .TouchUpInside)
        
        loginViewController.emailAsUsername = true
        loginViewController.signUpController?.delegate = self
        
        let imageView2 = UIImageView(image: UIImage(named: "Assassin"))
        imageView2.contentMode = UIViewContentMode.ScaleAspectFit
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
    }
    
  func fbLoginClick() {
    let permissions = ["public_profile", "email"] as [String]
    
    PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) { (user: PFUser?, error: NSError?) -> Void in
          if user == nil
          {
            if error == nil  {
                print("The user cancelled the Facebook login.")
            } else {
                print("An error occurred: \(error)")
            }
            
          } else if user!.isNew
          {
            self.presentLoggedInAlert()
            print("User signed up and logged in through Facebook! \(user)")
          } else {
            self.presentLoggedInAlert()
            print("User logged in through Facebook! \(user)")
        }
        }
    }
}


