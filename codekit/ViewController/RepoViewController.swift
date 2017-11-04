//
//  RepoViewController.swift
//  codekit
//
//  Created by 김기윤 on 04/11/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import UIKit

class RepoViewController: UIViewController {

    @IBOutlet weak var ownerTextField: UITextField!
    
    @IBOutlet weak var repoTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Enter 하기 전에 ViewController에 데이터를 셋팅
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EnterRepoSegue" {
            
        }
    }

}

extension RepoViewController {
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        GlobalState.instance.token = ""
        let loginViewController = LoginViewController.viewController
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0 ) {
            [weak self] in
            self?.present(loginViewController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func enterButtonTapped(_ sender: UIButton) {
        
    }
    
    
    
}
