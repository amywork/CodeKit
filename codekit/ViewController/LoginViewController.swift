//
//  LoginViewController.swift
//  codekit
//
//  Created by Kimkeeyun on 28/10/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    static var viewController: LoginViewController {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return LoginViewController() }
        return viewController
    }
    
    @IBAction func logingToGithubBtnTap(_ sender: Any) {
        App.api.getToken { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
}
