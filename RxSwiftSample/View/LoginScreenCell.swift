//
//  LoginScreenCell.swift
//  RxSwiftSample
//
//  Created by Nishinobu.Takahiro on 2016/03/15.
//  Copyright © 2016年 hachinobu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginScreenCell: UITableViewCell {

    @IBOutlet weak var validateErrorLabel: UILabel!
    @IBOutlet weak var loginIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    
    var disposeBag: DisposeBag! = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        disposeBag = nil
        disposeBag = DisposeBag()
    }

}
