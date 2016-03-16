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
        case Success
        case Error
        
        func isRequesting() -> Bool {
            return self == .Requesting
        }
        
        func requestState() -> (isHidden: Bool, isAnimation: Bool) {
            return self.isRequesting() ? (false, true) : (true, false)
        }
        
        func fetchFinishRequestMessage() -> String {
            switch self {
            case .Success:
                return "ログインに成功しました"
            case .Error:
                return "ログインに失敗しました"
            default:
                return ""
            }
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
    
    var successAlert: Observable<String> {
        return reqState.map { (reqState) -> String in
            return reqState.fetchFinishRequestMessage()
        }
    }
    
    let disposeBag = DisposeBag()
    
    init() {
        
        loginTap.filter { $0 }
            .withLatestFrom(userIdAndPassword)
            .flatMap { (userIdAndPassword: (loginId: String, password: String)) -> Observable<Bool> in
                
                self.reqState.onNext(.Requesting)
                return Observable.create { (observer) in
                    
                    let delay = 1.0 * Double(NSEC_PER_SEC)
                    let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                    
                    dispatch_after(time, dispatch_get_main_queue()) { _ in
                        if arc4random_uniform(2) == 0 {
                            observer.onNext(true)
                            return
                        }
                        observer.onNext(false)
                    }
                    
                    return NopDisposable.instance
                }
                
        }.subscribeNext { (result) -> Void in
            
            result ? self.reqState.onNext(.Success) : self.reqState.onNext(.Error)
            
        }.addDisposableTo(disposeBag)
        
    }
    
}