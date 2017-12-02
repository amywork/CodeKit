//
//  GroupListViewController.swift
//  RxTest
//
//  Created by leonard on 2017. 12. 2.
//  Copyright © 2017년 leonard. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

// 카테고리와 그룹 api를 받아서 짬뽕하는 것

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
        let items: Observable<[SectionModel<String, Group>]> = Observable.zip(GroupListAPI.groupList(), GroupListAPI.categoryList()) { (groups: [Group], categories: [Category]) -> [SectionModel<String, Group>] in
            return categories.map({ (category) -> SectionModel<String, Group> in
                let filteredGroups = groups.filter{ (group) -> Bool in
                    group.categoryID == category.ID
                }
                return SectionModel(model: category.name, items: filteredGroups)
            })
        }
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Group>>(configureCell: { (dataSource, tableView, indexPath, group) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
            cell.textLabel?.text = group.name
            return cell
        }, titleForHeaderInSection: { (dataSource, index) -> String? in
            return "\(dataSource.sectionModels[index].model) (\(dataSource.sectionModels[index].items.count))"
        })
        
        items.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
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
        let groups: [Group] =
            [Group(name: "1번째 그룹", categoryID: 1, ID: 1),
             Group(name: "2번째 그룹", categoryID: 1, ID: 2),
             Group(name: "3번째 그룹", categoryID: 1, ID: 3),
             Group(name: "4번째 그룹", categoryID: 1, ID: 4),
             Group(name: "5번째 그룹", categoryID: 2, ID: 5),
             Group(name: "6번째 그룹", categoryID: 2, ID: 6),
             Group(name: "7번째 그룹", categoryID: 2, ID: 7),
             Group(name: "8번째 그룹", categoryID: 2, ID: 8),
             Group(name: "9번째 그룹", categoryID: 3, ID: 9),
             Group(name: "10번째 그룹", categoryID: 3, ID: 10),
             Group(name: "11번째 그룹", categoryID: 3, ID: 11),
             Group(name: "12번째 그룹", categoryID: 4, ID: 12),
             Group(name: "13번째 그룹", categoryID: 4, ID: 13),
             Group(name: "14번째 그룹", categoryID: 4, ID: 14)]
        return Observable.just(groups).delay(0.5, scheduler: MainScheduler.instance)
    }
    
    static func categoryList() -> Observable<[Category]> {
        let categories: [Category] =
            [Category(name: "카테고리1", ID: 1, groups: [1,2,3]),
             Category(name: "카테고리2", ID: 2, groups: [4,5,6]),
             Category(name: "카테고리3", ID: 3, groups: [7,8,9]),
             Category(name: "카테고리4", ID: 4, groups: [10,11,12])]
        return Observable.just(categories).delay(0.7, scheduler: MainScheduler.instance)
    }
}
