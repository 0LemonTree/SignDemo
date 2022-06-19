//
//  SupplementaryDateViewController.swift
//  SignIn
//
//  Created by X on 2022/6/19.
//

import UIKit

protocol SupplementaryDateViewControllerDelegate:NSObjectProtocol {
    
    func checkHistoryAction(date:Date)
    func supplementaryActoin(date:Date);
}

class SupplementaryDateViewController: UIViewController {

    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    weak var delegate:SupplementaryDateViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let timeIns:TimeInterval = -(60*60*24)
        let todayDate = Date()
        datePicker.maximumDate = todayDate.addingTimeInterval(timeIns)
        checkDate(date: datePicker.maximumDate!)
    }

    @IBAction func closeAction(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    @IBAction func checkAction(_ sender: Any) {
        
        self.dismiss(animated: false)

        if checkBtn.currentTitle?.elementsEqual("未打卡 补卡") ?? false {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-DD"
            let dateStr = dateFormatter.string(from: datePicker.date)
            
            let newDate = Date()
            dateFormatter.dateFormat =  "HH:mm:ss"
            let newStr = dateFormatter.string(from: newDate)
            let newDateStr = dateStr + " " + newStr
            dateFormatter.dateFormat = "YYYY-MM-DD HH:mm:ss"
            let targetDate = dateFormatter.date(from: newDateStr)!
            delegate?.supplementaryActoin(date: targetDate)
        } else {
            
            delegate?.checkHistoryAction(date: datePicker.date)
        }
    }
 
    @IBAction func pickerValueChanged(_ sender: UIDatePicker) {
        
        checkDate(date: sender.date)
    }
    
    func checkDate(date:Date) {
        
        let dayId = DaySignRealmManager.shared.configDayId(date: date)
        let dayModel = DaySignRealmManager.shared.realm.object(ofType: DaySignInModel.self, forPrimaryKey: dayId)
        
        if dayModel == nil {
            
            checkBtn.setTitle("未打卡 补卡", for: .normal)
        } else {
            
            checkBtn.setTitle("已打卡 查看", for: .normal)
        }
    }
}
