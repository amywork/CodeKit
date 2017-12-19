//
//  CreateIssueViewController.swift
//  CodeKitApp
//
//  Created by Kimkeeyun on 17/12/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import Alamofire
import UIKit

class CreateIssueViewController: UIViewController {
   
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var bodyTextView: UITextView!
    
    var owner: String = ""
    var repo: String = ""
    
    var createdIssue: Model.Issue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
}

extension CreateIssueViewController {
    
    func setup() {
        bodyTextView.layer.borderColor = UIColor.lightGray.cgColor
        bodyTextView.layer.borderWidth = 1.0 / UIScreen.main.scale
        bodyTextView.layer.cornerRadius = 5
    }
    
    func uploadIssue() {
        let title = titleTextField.text ?? ""
        let body = bodyTextView.text ?? ""
        App.api.createIssue(owner: owner,
                            repo: repo,
                            title: title,
                            body: body)
        { [weak self] (response: DataResponse<Model.Issue>) in
            guard let `self` = self else { return }
            switch response.result {
            case .success(let issue):
                self.createdIssue = issue
                self.performSegue(withIdentifier: "UnwindToIssues", sender: self)
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        uploadIssue()
    }
    
}
