//
//  LostPasswordViewController.swift
//  Wishboard
//
//  Created by gomin on 2022/09/20.
//

import UIKit

class LostPasswordViewController: KeyboardViewController {
    var lostPasswordView: LostPasswordView!
    var email: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        super.navigationTitle.text = "이메일로 로그인하기"
        
        lostPasswordView = LostPasswordView()
        self.view.addSubview(lostPasswordView)
        
        lostPasswordView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(super.navigationView.snp.bottom)
        }
        lostPasswordView.emailTextField.addTarget(self, action: #selector(emailTextFieldEditingChanged(_:)), for: .editingChanged)
        lostPasswordView.getEmailButton.addTarget(self, action: #selector(getEmailButtonDidTap), for: .touchUpInside)
        
        super.textfield = lostPasswordView.emailTextField
    }
    override func viewDidAppear(_ animated: Bool) {
        lostPasswordView.emailTextField.becomeFirstResponder()
    }
    // MARK: - Actions
    @objc func emailTextFieldEditingChanged(_ sender: UITextField) {
        let text = sender.text ?? ""
        let trimString = text.trimmingCharacters(in: .whitespaces)
        self.lostPasswordView.emailTextField.text = trimString
        self.email = trimString
        self.checkValidEmail(self.email)
    }
    @objc func getEmailButtonDidTap() {
        let checkEmailInput = CheckEmailInput(email: self.email)
        LostPasswordDataManager().checkEmailDataManager(checkEmailInput, self)
    }
    // MARK: - Functions
    func checkValidEmail(_ email: String) {
        let isValid = self.email.checkEmail()
        if isValid {
            self.lostPasswordView.getEmailButton.then{
                $0.defaultButton("인증메일 받기", .wishboardGreen, .black)
                $0.isEnabled = true
            }
            self.lostPasswordView.errorMessage.isHidden = true
        } else {
            self.lostPasswordView.getEmailButton.then{
                $0.defaultButton("인증메일 받기", .wishboardDisabledGray, .dialogMessageColor)
                $0.isEnabled = false
            }
            self.lostPasswordView.errorMessage.isHidden = false
        }
    }
}
// MARK: - API Success
extension LostPasswordViewController {
    func checkEmailAPISuccess(_ result: APIModel<LostPasswordModel>) {
        let authCode = result.data?.verificationCode
        
        let getEmailVC = GetEmailViewController(title: "2/2 단계")
        getEmailVC.authCode = authCode
        getEmailVC.email = self.email
        
        self.navigationController?.pushViewController(getEmailVC, animated: true)
        print(result)
    }
    func checkEmaiAPIFail() {
        SnackBar(self, message: .login)
    }
}
