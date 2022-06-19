//
//  SupViewController.swift
//  SignIn
//
//  Created by X on 2022/6/19.
//

import UIKit

class SupViewController: UIViewController {

    var date:Date?
    var timeDisValue:TimeInterval = 0
    
    @IBOutlet weak var timesLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.text = DaySignRealmManager.shared.formatterDateToStr(date: date!, formatter: "YYYY-MM-dd")
        timesLabel.text = "已补0次"
        
        DaySignRealmManager.shared.supDelegate = self
        timeDisValue = Date().timeIntervalSince(date!)
    }

    @IBAction func suppleAction(_ sender: Any) {
        
        let newDate = Date().addingTimeInterval(-timeDisValue)
        DaySignRealmManager.shared.signIn(date: newDate, isSupplementary: true)
        
    }
}

extension SupViewController:DaySignRealmManagerSupDelegate {
    
    func supSuccess() {
        
        let dayId = DaySignRealmManager.shared.configDayId(date: date!)
        let dayModel = DaySignRealmManager.shared.realm.object(ofType: DaySignInModel.self, forPrimaryKey: dayId)
        timesLabel.text = "已补\(dayModel?.todaySigns.count ?? 0)次"
    }
}
