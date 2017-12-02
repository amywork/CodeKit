//
//  GroupListViewController.swift
//  RxTest
//
//  Created by leonard on 2017. 12. 2..
//  Copyright © 2017년 leonard. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class GroupListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

extension GroupListViewController {
    func bind() {
    
    }
}



struct Group {
    let name: String
    let categoryID: Int
    let ID: Int
}

struct Category {
    let name: String
    let ID: Int
    let groups: [Int]
}

struct GroupListAPI {
    static func groupList() -> Observable<[Group]> {
        return Observable.empty()
    }
    
    static func categoryList() -> Observable<[Category]> {
        return Observable.empty()
    }
}
