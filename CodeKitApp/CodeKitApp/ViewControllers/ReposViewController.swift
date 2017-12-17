//
//  ReposViewController.swift
//  CodeKitApp
//
//  Created by Kimkeeyun on 17/12/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import UIKit

let ReuseIdentifier: String = "RepoCell"
class ReposViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
   
    let datasource:[(owner: String, repo: String)] = GlobalState.shared.repos
    var selectedRepo: (owner: String, repo: String)?
    
}

extension ReposViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier, for: indexPath)
        let data = datasource[indexPath.row]
        cell.textLabel?.text = "\(data.owner), \(data.repo)"
        cell.detailTextLabel?.text = data.repo
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = datasource[indexPath.row]
        selectedRepo = data
        self.performSegue(withIdentifier: "UnwindToIssue", sender: self)
    }

}
