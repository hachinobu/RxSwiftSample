//
//  LoginScreenVM.swift
//  RxSwiftSample
//
//  Created by Nishinobu.Takahiro on 2016/03/15.
//  Copyright © 2016年 hachinobu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LoginScreenVM {
    
    enum RequestState {
        case None
        case Requesting
        case Complete
        case Error
        
        func isRequesting() -> Bool {
            return self == .Requesting
        }
        
        func requestState() -> (isHidden: Bool, isAnimation: Bool) {
            return self.isRequesting() ? (false, true) : (true, false)
        }
    }
    
    let reqState = BehaviorSubject<RequestState>(value: .None)
    let loginIdText = BehaviorSubject<String>(value: "")
    let passwordText = BehaviorSubject<String>(value: "")
    let loginTap = BehaviorSubject<Bool>(value: false)
    
    let userIdAndPassword: PublishSubject<(loginId: String, password: String)> = PublishSubject<(loginId: String, password: String)>()
    
    var loginButtonState: Observable<(alpha: CGFloat, enable: Bool)> {
        return Observable.combineLatest(loginIdText, passwordText, reqState) { [weak self] (loginId, password, reqState) in
            guard loginId.characters.count > 3 && password.characters.count > 3 && !reqState.isRequesting() else {
                return (0.5, false)
            }
            self?.userIdAndPassword.onNext((loginId, password))
            return (1.0, true)
        }
    }
    
    var validateErrorText: Observable<String> {
        return Observable.combineLatest(loginIdText, passwordText, reqState) { (loginId, password, reqState) in
            if loginId.characters.count == 0 {
                return "ログインIDを入力してください"
            }
            
            guard loginId.characters.count > 3 else {
                return "ログインIDは4文字以上です"
            }
            
            if password.characters.count == 0 {
                return "パスワードを入力してください"
            }
            
            guard password.characters.count > 3 else {
                return "パスワードは4文字以上です"
            }
            
            return ""
        }
    }
    
    var requestIndicatorState: Observable<(isHidden: Bool, isAnimation: Bool)> {
        return reqState.map { $0.requestState() }
    }
    
    var requestAPI: Observable<Void> {
        
        return Observable.combineLatest(loginTap, loginIdText, passwordText) { (isTap, loginId, password) -> Void in
            
            guard isTap else {
                return
            }
            
            self.reqState.onNext(.Requesting)
            let delay = 1.0 * Double(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(time, dispatch_get_main_queue()) { [unowned self] in
                self.reqState.onNext(.Complete)
            }
            
        }
    }
    
    func tapButton() {
        loginTap.onNext(true)
    }
    
}