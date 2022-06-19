//
//  HistoryViewController.swift
//  SignIn
//
//  Created by X on 2022/6/19.
//

import UIKit

class HistoryViewController: UITableViewController {
        
//    RealmResults< T>,可以不使用分页，因为RealmResults中的元素是惰性求值的,并且在调用.get(i)之前不在内存中.
    
    var delIndexPath = IndexPath()
    
    lazy var days = DaySignRealmManager.shared.realm.objects(DaySignInModel.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryViewControllerCellReuseIdentifier")
        
        DaySignRealmManager.shared.delDelegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        DaySignRealmManager.shared.delDelegate = nil
    }
    
    func signDelSuccess(indexPath:IndexPath)  {
        
        let dayModel = days[indexPath.section]
        
        if dayModel.todaySigns.count == 0 {
            
            DaySignRealmManager.shared.removeDay(dayModel: dayModel)
            tableView.reloadData()

        } else {
            
            tableView.deleteRows(at: [indexPath], with: .none)
        }
    }
    
    func dayDelSuccessed(indexPath:IndexPath) {
        
       if tableView.visibleCells.count == 1 {
            
            tableView.reloadData()
        } else {
            
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .none)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return days.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sigleDay = days[section]
        return sigleDay.todaySigns.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryViewControllerCellReuseIdentifier", for: indexPath)

        let sigleDay = days[indexPath.section]
        let todaySigns = sigleDay.todaySigns
        let signModel = todaySigns[indexPath.row]
    
        guard let signDate = signModel.signDate else {
            
            cell.textLabel?.text = "时间解析错误"
            return cell
        }
        
        cell.textLabel?.text = "打卡时间：" + DaySignRealmManager.shared.formatterDateToStr(date: signDate, formatter: "HH:mm:ss")
        return cell
    }
     
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sigleDay = days[section]
        let daySign = sigleDay.todaySigns.first
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter.string(from: daySign!.signDate!)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            delIndexPath = indexPath

            let sigleDay = days[indexPath.section]
            let todaySigns = sigleDay.todaySigns
            let signModel = todaySigns[indexPath.row]
            DaySignRealmManager.shared.removeSign(signModel: signModel)
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        return .delete
    }
}

extension HistoryViewController:DaySignRealmManagerDelDelegate {
    
    func delSuccess(signModel: EveryDaySignModel) {
        
        signDelSuccess(indexPath: delIndexPath);
    }
    
    func dayDelSuccess(dayModel: DaySignInModel) {
        
        dayDelSuccessed(indexPath: delIndexPath)
    }
}
