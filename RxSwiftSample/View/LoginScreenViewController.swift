//
//  LoginScreenViewController.swift
//  RxSwiftSample
//
//  Created by Nishinobu.Takahiro on 2016/03/15.
//  Copyright © 2016年 hachinobu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginScreenViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var viewModel = LoginScreenVM()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        bindStaticUI()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func bindStaticUI() {
        viewModel.successAlert.filter { $0 != "" }.subscribeNext { (message) -> Void in
            let alert = UIAlertController(title: "結果", message: message, preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }.addDisposableTo(disposeBag)
    }
    
}


extension LoginScreenViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LoginScreenCell", forIndexPath: indexPath) as! LoginScreenCell
        
        //エラーラベル
        viewModel.validateErrorText.bindTo(cell.validateErrorLabel.rx_text).addDisposableTo(cell.disposeBag)
        
        //ログインID
        viewModel.loginIdText.bindTo(cell.loginIdTextField.rx_text).addDisposableTo(cell.disposeBag)
        cell.loginIdTextField.rx_text.subscribeNext { [weak self] (text) -> Void in
            self?.viewModel.loginIdText.onNext(text)
        }.addDisposableTo(cell.disposeBag)
        
        //パスワード
        viewModel.passwordText.bindTo(cell.passwordTextField.rx_text).addDisposableTo(cell.disposeBag)
        cell.passwordTextField.rx_text.subscribeNext { (text) -> Void in
            self.viewModel.passwordText.onNext(text)
        }.addDisposableTo(cell.disposeBag)
        
        //通信インディケーターの状態
        viewModel.requestIndicatorState.subscribeNext { (state: (isHidden: Bool, isAnimation: Bool)) -> Void in
            cell.loginIndicator.hidden = state.isHidden
            state.isAnimation ? cell.loginIndicator.startAnimating() : cell.loginIndicator.stopAnimating()
        }.addDisposableTo(cell.disposeBag)
        
        //ログインボタンの状態
        viewModel.loginButtonState.subscribeNext { (state: (alpha: CGFloat, enable: Bool)) -> Void in
            cell.loginButton.alpha = state.alpha
            cell.loginButton.enabled = state.enable
        }.addDisposableTo(cell.disposeBag)
        
        
        //ログインボタン押下判定
        cell.loginButton.rx_tap.map { true }.bindTo(viewModel.loginTap).addDisposableTo(cell.disposeBag)
        
        return cell
    }
    
}

extension LoginScreenViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    
}