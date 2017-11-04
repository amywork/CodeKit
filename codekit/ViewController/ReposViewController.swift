//
//  ReposViewController.swift
//  codekit
//
//  Created by 김기윤 on 04/11/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//  BookMark

import UIKit

class ReposViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let datasource:[(owner: String, repo: String)] = GlobalState.instance.repos
    var selectedRepo: (owner: String, repo: String)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

let ReuseIdentifier: String = "RepoCell"
extension ReposViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier, for: indexPath)
        let data = datasource[indexPath.row]
        cell.textLabel?.text = "\(data.owner), \(data.repo)"
        cell.detailTextLabel?.text = datasource[indexPath.row].repo
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = datasource[indexPath.row]
        selectedRepo = data
        self.performSegue(withIdentifier: "UnwindToIssue", sender: self)
    }
    
}
