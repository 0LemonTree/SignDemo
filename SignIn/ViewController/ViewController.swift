//
//  ViewController.swift
//  SignIn
//
//  Created by X on 2022/6/17.
//

import UIKit
import RealmSwift
import Toaster

class ViewController: UIViewController {

    /// 今日次数
    @IBOutlet weak var todayTimeLabel: UILabel!
    /// 历史共计次数
    @IBOutlet weak var reconrdLabel: UILabel!
    /// 历史连续最高次数，当前连续次数
    @IBOutlet weak var recordMaxLabel: UILabel!

    lazy var realm:Realm = {
        
        return DaySignRealmManager.shared.realm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
    }
    
//MARK: - - - config
    
    func config() {
        
        DaySignRealmManager.shared.delegate = self
        configReconrdNum()
        configTodaySignNum()
    }

//MARK: - - - methods
    
    func configReconrdNum() {
        
        guard let historyNumModel = realm.object(ofType: SignInNumModel.self, forPrimaryKey: 0) else {
            
            changeHistroyNum(historyMaxNum: 0, currentNum: 0, totalSignNum: "0")
            return
        }
        changeHistroyNum(historyMaxNum: historyNumModel.historyMaxNum, currentNum: historyNumModel.curentNum, totalSignNum: historyNumModel.totalNum)
    }
    
    func configTodaySignNum () {
        
        let todayModelId = DaySignRealmManager.shared.configDayId()
        guard let todaySignModel = realm.object(ofType: DaySignInModel.self, forPrimaryKey: todayModelId) else {
            
            changeTodaySignNum(todaySignNum: 0)
            return
        }
        
        changeTodaySignNum(todaySignNum: todaySignModel.todaySigns.count)
    }
    
    func changeHistroyNum(historyMaxNum:Int, currentNum:Int, totalSignNum:String) {
        
        recordMaxLabel.text = "历史最高连续天数：\(historyMaxNum) \n 当前连续天数：\(currentNum)"
        reconrdLabel.text = "历史总打卡次数：" + totalSignNum
    }
    
    func changeTodaySignNum(todaySignNum:Int) {
        
        todayTimeLabel.text = "今日打卡次数：\(todaySignNum)"
    }
    
    func changeTotalSignNum(totalSignNum:Int) {
        
        reconrdLabel.text = "总计打卡次数：\(totalSignNum)"
    }
    
    @IBAction func signAction(_ sender: Any) {
        
        DaySignRealmManager.shared.signIn(date: Date())
    }
    
    @IBAction func todayHistory(_ sender: Any) {
        
        let date = Date()
        let todayHistoryVC = TodayHistoryViewController()
        todayHistoryVC.date = date
        present(todayHistoryVC, animated: true)
    }
    
    @IBAction func SupplementaryAction(_ sender: Any) {
        
        let supplementVC = SupplementaryDateViewController()
        supplementVC.delegate = self
        present(supplementVC, animated: true)
    }
    
    @IBAction func dateHistory(_ sender: Any) {
        
        let historyVC = HistoryViewController()
        present(historyVC, animated: true)
    }
}

extension ViewController : DaySignRealmManagerDelegate {
    
    func signSuccess() {
        
        configReconrdNum()
        configTodaySignNum()
    }
    
    func signFail(errorStr: String) {
        
        Toast(text: errorStr).show()
    }
}

extension ViewController:SupplementaryDateViewControllerDelegate {
    
    func checkHistoryAction(date: Date) {
        
        let checkHistoryVC = TodayHistoryViewController()
        checkHistoryVC.date = date
        present(checkHistoryVC, animated: true)
    }
    
    func supplementaryActoin(date: Date) {
        
        let supVC = SupViewController()
        supVC.date = date
        present(supVC, animated: true)
    }
}

