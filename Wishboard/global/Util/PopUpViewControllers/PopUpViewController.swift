//
//  PopUpViewController.swift
//  Wishboard
//
//  Created by gomin on 2022/09/14.
//

import UIKit

struct PopUpModel {
    let title: String
    let message: String
    var greenBtnText: String?
    var blackBtnText: String?
    var btnText: String?
}

enum PopUpType {
    case normal
    case delete
}

// Default 팝업창
class PopUpViewController: UIViewController {
    // MARK: - Properties
    private var titleText: String!
    private var messageText: String!
    private var greenBtnText: String!
    private var blackBtnText: String!
    
    let popupView = UIView().then{
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
        
        $0.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }
    let titleLabel = DefaultLabel().then{
        $0.setTypoStyleWithSingleLine(typoStyle: .SuitH3)
    }
    let messageLabel = UILabel().then{
        $0.setTypoStyleWithMultiLine(typoStyle: .SuitD2)
        $0.textColor = .gray_300
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    let horizontalSeperator = UIView().then{
        $0.backgroundColor = .gray_100
    }
    let verticalSeperator = UIView().then{
        $0.backgroundColor = .gray_100
    }
    var cancelBtn: UIButton!
    var okBtn: UIButton!
    
    var type: PopUpType?
    
    // MARK: - Life Cycles
    convenience init(_ model: PopUpModel, _ type: PopUpType? = .normal) {
        self.init()
        
        self.titleText = model.title
        self.messageText = model.message
        self.greenBtnText = model.greenBtnText ?? ""
        self.blackBtnText = model.blackBtnText ?? ""
        
        self.type = type
        
        setUpContent()
        setUpView()
        setUpConstraint()
        
        modalPresentationStyle = .overFullScreen
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black_4

        cancelBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // curveEaseOut: 시작은 천천히, 끝날 땐 빠르게
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut) { [weak self] in
            self?.popupView.transform = .identity
            self?.popupView.isHidden = false
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // curveEaseIn: 시작은 빠르게, 끝날 땐 천천히
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn) { [weak self] in
            self?.popupView.transform = .identity
            self?.popupView.isHidden = true
        }
    }
    // MARK: - Actions
    @objc func goBack() {
        self.dismiss(animated: false)
    }
    // MARK: - Functions
    func setUpContent() {
        titleLabel.text = self.titleText
        messageLabel.text = self.messageText
        cancelBtn = UIButton().then{
            var config = UIButton.Configuration.plain()
            var attText = AttributedString.init(self.blackBtnText!)
            
            attText.font = TypoStyle.SuitB3.font
            attText.foregroundColor = self.type == .normal ? UIColor.gray_700 : UIColor.gray_700
            config.attributedTitle = attText
            
            $0.configuration = config
        }
        okBtn = UIButton().then{
            var config = UIButton.Configuration.plain()
            var attText = AttributedString.init(self.greenBtnText!)
            
            attText.font = TypoStyle.SuitB3.font
            attText.foregroundColor = self.type == .normal ? UIColor.green_700 : UIColor.pink_700
            config.attributedTitle = attText
            
            $0.configuration = config
        }
    }
    func setUpView() {
        self.view.addSubview(popupView)
        
        popupView.addSubview(titleLabel)
        popupView.addSubview(messageLabel)
        popupView.addSubview(horizontalSeperator)
        popupView.addSubview(verticalSeperator)
        popupView.addSubview(cancelBtn)
        popupView.addSubview(okBtn)
    }
    func setUpConstraint() {
        popupView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.greaterThanOrEqualTo(148)
            make.centerY.centerX.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
        }
        horizontalSeperator.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview().offset(-48)
            make.leading.trailing.equalToSuperview()
        }
        messageLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(28)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(horizontalSeperator.snp.top).offset(-32)
        }
        verticalSeperator.snp.makeConstraints { make in
            make.width.equalTo(0.5)
            make.bottom.centerX.equalToSuperview()
            make.top.equalTo(horizontalSeperator.snp.bottom)
        }
        cancelBtn.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.top.equalTo(horizontalSeperator.snp.bottom)
            make.leading.bottom.equalToSuperview()
            make.trailing.equalTo(verticalSeperator.snp.leading)
        }
        okBtn.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.centerY.equalTo(cancelBtn)
            make.trailing.bottom.equalToSuperview()
            make.leading.equalTo(verticalSeperator.snp.trailing)
        }
    }
}

class OneButtonPopUpViewController: UIViewController {
    // MARK: - Properties
    private var titleText: String!
    private var messageText: String!
    private var btnText: String!
    
    let popupView = UIView().then{
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
        
        $0.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }
    let titleLabel = DefaultLabel().then{
        $0.setTypoStyleWithSingleLine(typoStyle: .SuitH3)
    }
    let messageLabel = UILabel().then{
        $0.setTypoStyleWithMultiLine(typoStyle: .SuitD2)
        $0.textColor = .gray_300
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    let horizontalSeperator = UIView().then{
        $0.backgroundColor = .gray_100
    }
    
    var okBtn: UIButton!
    
    // MARK: - Life Cycles
    convenience init(_ model: PopUpModel) {
        self.init()
        
        self.titleText = model.title
        self.messageText = model.message
        self.btnText = model.btnText ?? ""
        
        setUpContent()
        setUpView()
        setUpConstraint()
        
        modalPresentationStyle = .overFullScreen
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black_4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // curveEaseOut: 시작은 천천히, 끝날 땐 빠르게
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut) { [weak self] in
            self?.popupView.transform = .identity
            self?.popupView.isHidden = false
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // curveEaseIn: 시작은 빠르게, 끝날 땐 천천히
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn) { [weak self] in
            self?.popupView.transform = .identity
            self?.popupView.isHidden = true
        }
    }
    // MARK: - Actions
    @objc func goBack() {
        self.dismiss(animated: false)
    }
    // MARK: - Functions
    func setUpContent() {
        titleLabel.text = self.titleText
        messageLabel.text = self.messageText
        okBtn = UIButton().then{
            var config = UIButton.Configuration.plain()
            var attText = AttributedString.init(self.btnText!)
            
            attText.font = TypoStyle.SuitB3.font
            attText.foregroundColor = UIColor.green_700
            config.attributedTitle = attText
            
            $0.configuration = config
        }
    }
    func setUpView() {
        self.view.addSubview(popupView)
        
        popupView.addSubview(titleLabel)
        popupView.addSubview(messageLabel)
        popupView.addSubview(horizontalSeperator)
        popupView.addSubview(okBtn)
    }
    func setUpConstraint() {
        popupView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.greaterThanOrEqualTo(148)
            make.centerY.centerX.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
        }
        horizontalSeperator.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview().offset(-48)
            make.leading.trailing.equalToSuperview()
        }
        messageLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(28)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(horizontalSeperator.snp.top).offset(-32)
        }
        okBtn.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(horizontalSeperator.snp.bottom)
        }
    }
}
