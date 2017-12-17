//
//  RepoViewController.swift
//  CodeKitApp
//
//  Created by Kimkeeyun on 17/12/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import UIKit

class RepoViewController: UIViewController {

    @IBOutlet weak var ownerTextField: UITextField!
    @IBOutlet weak var repoTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ownerTextField.text = GlobalState.shared.owner
        repoTextField.text = GlobalState.shared.repo
    }

    
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if segue.identifier == "EnterRepoSegue" {
            guard let owner = ownerTextField.text,
                let repo = repoTextField.text else {
                    UIAlertController.presentAlertController(target: self,
                                                             title: "텍스트를 모두 입력하세요",
                                                             massage: nil,
                                                             cancelBtn: false,
                                                             completion: nil)
                    return }
            GlobalState.shared.owner = owner
            GlobalState.shared.repo = repo
            GlobalState.shared.addRepo(owner: owner, repo: repo)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String,
                                     sender: Any?) -> Bool {
        if identifier == "EnterRepoSegue" {
            guard let owner = ownerTextField.text,
                let repo = repoTextField.text else { return false }
            return !(owner.isEmpty || repo.isEmpty)
        }
        return true
    }

}

extension RepoViewController {
    
    @IBAction func logoutBtnHandler(_ sender: UIBarButtonItem) {
        GlobalState.shared.token = ""
        let loginViewController = LoginViewController.viewController
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 ) {
            [weak self] in
            self?.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func unwindFromRepos(_ segue: UIStoryboardSegue) {
        guard let reposController = segue.source as? ReposViewController else { return }
        guard let (owner, repo) = reposController.selectedRepo else { return }
        GlobalState.shared.owner = owner
        GlobalState.shared.repo = repo
        ownerTextField.text = owner
        repoTextField.text = repo
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.0) {
            [weak self] in
            self?.performSegue(withIdentifier: "EnterRepoSegue", sender: nil)
        }
        
    }
    
}

extension RepoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension UIAlertController {
    
    static func presentAlertController(target: UIViewController,
                                       title: String?,
                                       massage: String?,
                                       actionStyle: UIAlertActionStyle = UIAlertActionStyle.default,
                                       cancelBtn: Bool,
                                       completion: ((UIAlertAction)->Void)?) {
        
        let alert = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: actionStyle, handler: completion)
        alert.addAction(okAction)
        if cancelBtn {
            let cancelAction = UIAlertAction(title: "Cancel", style: actionStyle, handler: completion)
            alert.addAction(cancelAction)
        }
        
        target.present(alert, animated: true, completion: nil)
    }
    
}

