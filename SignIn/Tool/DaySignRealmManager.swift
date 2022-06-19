//
//  DaySignRealmManager.swift
//  SignIn
//
//  Created by X on 2022/6/17.
//

import UIKit
import RealmSwift
import Toaster

protocol DaySignRealmManagerSupDelegate:NSObjectProtocol {
    
    func supSuccess()
}

protocol DaySignRealmManagerDelDelegate:NSObjectProtocol {
    
    func delSuccess(signModel:EveryDaySignModel)
    func dayDelSuccess(dayModel:DaySignInModel)
}

protocol DaySignRealmManagerDelegate:NSObjectProtocol {
    
    func signFail(errorStr:String)
    func signSuccess()
}

class DaySignRealmManager: NSObject {

    static let shared = DaySignRealmManager()
    let realm = try! Realm()
    
    private override init() {}
    weak var delegate:DaySignRealmManagerDelegate?
    weak var delDelegate:DaySignRealmManagerDelDelegate?
    weak var supDelegate:DaySignRealmManagerSupDelegate?

    override func copy() -> Any {
         
        return self
    }
       
    override func mutableCopy() -> Any {
          
        return self
    }
    
    func configMonthId(date:Date = Date()) -> Int {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMM"
        let dateStr = dateFormatter.string(from: date)
        return Int(dateStr) ?? -1
    }
    
    func configDayId(date:Date = Date()) -> Int {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMDD"
        let dateStr = dateFormatter.string(from: date)
        return Int(dateStr) ?? -1
    }
    
    func configTimeId(date:Date = Date()) -> Int {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMDDHHmmss"
        let dateStr = dateFormatter.string(from: date)
        return Int(dateStr) ?? -1
    }
    
    func signIn(date:Date = Date(), isSupplementary:Bool = false) {
        
        var historyNumModel = realm.object(ofType: SignInNumModel.self, forPrimaryKey: 0)
        if historyNumModel == nil {
            
            historyNumModel = SignInNumModel()
            try! realm.write {
                
                realm.add(historyNumModel!)
            }
        }
        
        guard let _ = addTimeSign(date: date) else {
            
            return
        }
        
        guard let signNumModel = realm.object(ofType: SignInNumModel.self, forPrimaryKey: 0) else {
            
            delegate?.signFail(errorStr: "打卡次数更新失败")
            return
        }
        
        do {
            
            try realm.write({ [weak self] in
                
                self?.updateNums(date: date, numModel: signNumModel, isSupplementary: isSupplementary)
            })
            
        } catch {
            
            delegate?.signFail(errorStr: "打卡次数更新失败" + error.localizedDescription)
        }
    }
    
    func addDaySign(date:Date = Date()) -> DaySignInModel? {
        
        let dayId = configDayId(date: date)
        
        guard let dayModel = realm.object(ofType: DaySignInModel.self, forPrimaryKey: dayId) else {
            
            let dayModel = DaySignInModel()
            dayModel.id = dayId
            dayModel.todaySigns = List()
            
            do {
                
                guard let monthModel = addMonthSign(date: date) else { return nil  }

                try realm.write({
                    
                    realm.add(dayModel)
                    monthModel.daySigns.append(dayModel)
                })
                
                return dayModel
            } catch {
               
                delegate?.signFail(errorStr: "打卡失败- \(error.localizedDescription)")
                return nil
            }
        }
        
        return dayModel
    }
    
    func addTimeSign(date:Date = Date()) -> EveryDaySignModel? {
        
        let timeId = configTimeId(date: date)
                
        guard realm.object(ofType: EveryDaySignModel.self, forPrimaryKey: timeId) != nil else {
            
            let timeModel = EveryDaySignModel()
            timeModel.id = timeId
            timeModel.signDate = date
            
            do {
                
                guard let dayModel = addDaySign(date: date) else { return nil  }

                try realm.write({
                    
                    realm.add(timeModel)
                    dayModel.todaySigns.append(timeModel)
                })
                
                return timeModel
            } catch {
               
                delegate?.signFail(errorStr: "打卡失败- \(error.localizedDescription)")
                return nil
            }
        }
        
        delegate?.signFail(errorStr: "打卡失败- 最小间隔为 1 秒")
        
        return nil
    }
    
    func addMonthSign(date:Date = Date()) -> MonthSignInModel? {
        
        let monthId = configMonthId(date: date)
        guard let monthModel = realm.object(ofType: MonthSignInModel.self, forPrimaryKey: monthId) else {
            
            let monthModel = MonthSignInModel()
            monthModel.id = monthId
            monthModel.daySigns = List()
            
            do {
                
                try realm.write({
                    
                    realm.add(monthModel)
                })
                
                return monthModel
            } catch {
                
                delegate?.signFail(errorStr: "打卡失败- \(error.localizedDescription)")
                return nil
            }
        }
        
        return monthModel
    }
    
    func updateNums(date:Date!, numModel:SignInNumModel, isSupplementary:Bool = false) {
        
        var totalNum = UInt(numModel.totalNum) ?? 0
        totalNum += 1

        numModel.totalNum = "\(totalNum)"
        
        if !isSupplementary {
            
            if checkCoutinue(date: date ,numModel: numModel) {
                    
                    numModel.curentNum += 1
                
            } else {
                    
                    if numModel.curentNum == 0 {
                        
                        numModel.curentNum = 1
                    } else {
                        
                        let dayNums = realm.objects(DaySignInModel.self).count
                        
                        if dayNums != 1 {
                            
                            if numModel.historyMaxNum < numModel.curentNum {
                                
                                numModel.historyMaxNum = numModel.curentNum
                            }
                        }
                    }
            }
            
        }
        
        supDelegate?.supSuccess()
        delegate?.signSuccess()
    }
    
    func checkCoutinue(date:Date = Date(), numModel:SignInNumModel) -> Bool {
                
        let timeInt:TimeInterval = -(60 * 60 * 24)
        let yesterdayDate = date.addingTimeInterval(timeInt)
        let dayId = configDayId(date: yesterdayDate)
        let dayModel = realm.object(ofType: DaySignInModel.self, forPrimaryKey: dayId)
        return (dayModel != nil)
    }
    
    func formatterDateToStr(date:Date, formatter:String = "YYYY年MM月dd日-HH:mm:ss") -> String {
        
        let dateFormatter = DateFormatter()
       
        dateFormatter.dateFormat = formatter
        return dateFormatter.string(from: date)
    }
    
    func removeSign(signModel:EveryDaySignModel?) {
        
        guard let daySignModel = signModel else {
            
            Toast.init(text: "删除失败").show()
            return
        }
        do {
            
            guard let signModel = realm.object(ofType: EveryDaySignModel.self, forPrimaryKey: daySignModel.id) else {
                
                Toast.init(text: "删除失败").show()
                return
            }
            
            let dayId = configDayId(date: signModel.signDate!)
            let todayModel = realm.object(ofType: DaySignInModel.self, forPrimaryKey: dayId)
            let numModel = realm.object(ofType: SignInNumModel.self, forPrimaryKey: 0)
            
            var totalUNum = UInt(numModel!.totalNum) ?? 0
            totalUNum -= 1
            
            try realm.write({
                
                todayModel?.todaySigns.realm?.delete(signModel)
                numModel?.totalNum = "\(totalUNum)"
            })

            delDelegate?.delSuccess(signModel: signModel)
            delegate?.signSuccess()
        } catch {
            
            Toast.init(text: "删除失败 - \(error.localizedDescription)").show()
        }
    }
    
    func removeDay(dayModel:DaySignInModel) {
        
#warning ("- - - 历史连续记录- -未更新")
        
        do {
            
            let dateFormatter = DateFormatter()
            let formatterStr = "\(dayModel.id)"
            dateFormatter.dateFormat = formatterStr
           
            let startIndex = formatterStr.startIndex
            let endRange = formatterStr.index(startIndex, offsetBy: 5)
            let monthIdStr = formatterStr[startIndex...endRange]
            let monthId = Int(monthIdStr) ?? 0
            
            guard let monthModel = realm.object(ofType: MonthSignInModel.self, forPrimaryKey: monthId) else {
                
                return
            }
            
            let numModel = realm.object(ofType: SignInNumModel.self, forPrimaryKey: 0)
            
            var curNum = numModel?.curentNum ?? 0
            curNum -= 1
            
            try realm.write({
                
                monthModel.daySigns.realm?.delete(dayModel)
                if monthModel.daySigns.isEmpty {

                    realm.delete(monthModel)
                }
                numModel?.curentNum = curNum
            })
            
            delDelegate?.dayDelSuccess(dayModel: dayModel)
            delegate?.signSuccess()
        } catch {
            
            Toast.init(text: error.localizedDescription).show()
        }
    }
}
