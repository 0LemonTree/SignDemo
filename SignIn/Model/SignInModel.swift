//
//  DaySignInModel.swift
//  SignIn
//
//  Created by X on 2022/6/17.
//

import UIKit
import RealmSwift

class MonthSignInModel:Object {
    
    @Persisted(primaryKey: true) var id = 0
    @Persisted var daySigns:List<DaySignInModel>
}

class DaySignInModel: Object {
    
    @Persisted(primaryKey: true) var id = 0
    @Persisted var todaySigns:List<EveryDaySignModel>
}

class EveryDaySignModel:Object {
    
    @Persisted(primaryKey: true) var id = 0
    @Persisted var signDate:Date?
}

class SignInNumModel:Object {
    
    @Persisted(primaryKey: true) var id = 0
    @Persisted var historyMaxNum:Int = 0
    @Persisted var curentNum:Int = 0
    @Persisted var totalNum:String = "0"
    
}
