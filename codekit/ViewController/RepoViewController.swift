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
    
    // Enter 하기 전에 ViewController에 Owner, Repo 데이터를 셋팅
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EnterRepoSegue" {
            guard let owner = ownerTextField.text, let repo = repoTextField.text else { return }
            GlobalState.instance.owner = owner
            GlobalState.instance.repo = repo
            GlobalState.instance.addRepo(owner: owner, repo: repo)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "EnterRepoSegue" {
            guard let owner = ownerTextField.text, let repo = repoTextField.text else { return false }
            return !(owner.isEmpty || repo.isEmpty)
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ownerTextField.text = GlobalState.instance.owner
        repoTextField.text = GlobalState.instance.repo
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
    
    @IBAction func unwindFromRepos(_ segue: UIStoryboardSegue) {
        guard let reposViewController = segue.source as? ReposViewController else { return }
        guard let (owner, repo) = reposViewController.selectedRepo else { return }
        ownerTextField.text = owner
        repoTextField.text = repo
        GlobalState.instance.owner = owner
        GlobalState.instance.repo = repo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0 ) {
            [weak self] in
            self?.performSegue(withIdentifier: "EnterRepoSegue", sender: nil)
        }
    }
    
}
