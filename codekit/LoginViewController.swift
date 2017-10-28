//
//  LoginViewController.swift
//  codekit
//
//  Created by Kimkeeyun on 28/10/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBAction func logingToGithubBtnTap(_ sender: Any) {
        App.api.getToken {
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
