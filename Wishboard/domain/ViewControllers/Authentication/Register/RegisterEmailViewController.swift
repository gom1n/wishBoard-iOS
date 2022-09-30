//
//  RegisterEmailViewController.swift
//  Wishboard
//
//  Created by gomin on 2022/09/19.
//

import UIKit

class RegisterEmailViewController: UIViewController {
    var registerEmailView: RegisterEmailView!
    var email: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.navigationController?.isNavigationBarHidden = true
        
        registerEmailView = RegisterEmailView()
        self.view.addSubview(registerEmailView)
        
        registerEmailView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        registerEmailView.backBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        registerEmailView.emailTextField.addTarget(self, action: #selector(emailTextFieldEditingChanged(_:)), for: .editingChanged)
        registerEmailView.nextButton.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
    }
    override func viewDidAppear(_ animated: Bool) {
        registerEmailView.emailTextField.becomeFirstResponder()
    }
    // MARK: - Actions
    @objc func goBack() {
        self.dismiss(animated: true)
    }
    @objc func emailTextFieldEditingChanged(_ sender: UITextField) {
        let text = sender.text ?? ""
        self.email = text
        self.checkValidEmail(self.email)
    }
    @objc func nextButtonDidTap() {
        self.view.endEditing(true)
        let checkEmailInput = CheckEmailInput(email: self.email)
        RegisterDataManager().checkEmailDataManager(checkEmailInput, self)
    }
    // MARK: - Functions
    func checkValidEmail(_ email: String) {
        let isValid = self.email.checkEmail()
        if isValid {
            self.registerEmailView.nextButton.then{
                $0.defaultButton("다음", .wishboardGreen, .black)
                $0.isEnabled = true
            }
        } else {
            self.registerEmailView.nextButton.then{
                $0.defaultButton("다음", .wishboardDisabledGray, .black)
                $0.isEnabled = false
            }
        }
    }
}
// MARK: - API Success
extension RegisterEmailViewController {
    func checkEmailAPISuccess(_ result: APIModel<ResultModel>) {
        let registerVC = RegisterPasswordViewController()
        registerVC.email = self.email
        registerVC.modalPresentationStyle = .fullScreen
        self.present(registerVC, animated: true, completion: nil)
    }
    func checkEmaiAPIFail() {
        SnackBar(self, message: .checkEmail)
    }
}
