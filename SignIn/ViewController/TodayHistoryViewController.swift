//
//  TodayHistoryViewController.swift
//  SignIn
//
//  Created by X on 2022/6/19.
//

import UIKit
import Toaster
import RealmSwift

class TodayHistoryViewController: UITableViewController {
        
    let realm = DaySignRealmManager.shared.realm
    var date:Date?
    
    lazy var dayModel:DaySignInModel? = {
        
        let dayId = DaySignRealmManager.shared.configDayId(date: date!)
        let dayModel = realm.object(ofType: DaySignInModel.self, forPrimaryKey: dayId)
        
        return dayModel
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TodayHistoryViewControllerCellReuseIdentifier")
        DaySignRealmManager.shared.delDelegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        DaySignRealmManager.shared.delDelegate = nil
    }
    
//MARK: - - - methods
    
    func signDelSuccess(indexPath:IndexPath)  {
        
        if dayModel?.todaySigns.count == 0 {
            
            DaySignRealmManager.shared.removeDay(dayModel: dayModel!)
        }
                
        if tableView.visibleCells.count == 1 {

            tableView.reloadData()
        } else {

            tableView.deleteRows(at: [indexPath], with: .none)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dayModel?.todaySigns.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayHistoryViewControllerCellReuseIdentifier", for: indexPath)

        let todaySigns = dayModel?.todaySigns
        
        let signModel = todaySigns?[indexPath.row]
        
    
        guard let signDate = signModel?.signDate else {
            
            cell.textLabel?.text = "时间解析错误"
            return cell
        }
        
        cell.textLabel?.text = "今日 打卡时间：" + DaySignRealmManager.shared.formatterDateToStr(date: signDate)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let signModel = dayModel?.todaySigns[indexPath.row]
            DaySignRealmManager.shared.removeSign(signModel: signModel)
//            let _ = signModel?.observe({[weak self] change in
//                
//                switch change {
//                case .deleted:
                    
//                    self?.delSuccess(indexPath: indexPath)
//                default:
//                    break
//                }
//            })
        }
    }
}

extension TodayHistoryViewController:DaySignRealmManagerDelDelegate {
    
    func delSuccess(signModel: EveryDaySignModel) {
        
        let indexPath = IndexPath(row: dayModel?.todaySigns.firstIndex(of: signModel) ?? 0, section: 0)
        signDelSuccess(indexPath: indexPath)
    }
    
    func dayDelSuccess(dayModel: DaySignInModel) {
        
        self.dayModel = nil
    }
}
