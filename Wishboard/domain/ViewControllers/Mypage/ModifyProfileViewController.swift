//
//  ModifyProfileViewController.swift
//  Wishboard
//
//  Created by gomin on 2022/09/09.
//

import UIKit
import Kingfisher

class ModifyProfileViewController: TitleCenterViewController {
    var observer = UserObserver.shared
    
    // profile
    var profileImage = UIImageView().then{
        $0.image = Image.defaultProfile
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 53
        $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = true
    }
    let cameraButton = UIButton().then{
        $0.setImage(Image.cameraGray, for: .normal)
    }
    let nicknameLabel = DefaultLabel().then{
        $0.text = Message.nickName
        $0.setTypoStyleWithSingleLine(typoStyle: .SuitB3)
    }
    var nameTextField = DefaultTextField(Placeholder.nickname).then{
        $0.clearButtonMode = .always
        $0.becomeFirstResponder()
    }
    let completeButton = LoadingButton(Button.complete)
    let completeKeyboardButton = LoadingButton(Button.complete)
    lazy var accessoryView: UIView = {
        return UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 72.0))
    }()
    // MARK: - Life Cycles
    // 앨범 선택 image picker
    let imagePickerController = UIImagePickerController()
    var selectedPhoto: UIImage?
    var nickname: String?
    
    var preNickName: String?
    var preProfileImg: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.navigationController?.isNavigationBarHidden = true
        super.navigationTitle.text = Title.modifyProfile
        
        // imagePicker delegate
        imagePickerController.delegate = self
        
        setUpView()
        setUpConstraint()
        setTarget()
        
        nameTextField.inputAccessoryView = accessoryView // <-
        
        self.nameTextField.delegate = self
    }
    /// will disappear
    override func viewWillDisappear(_ animated: Bool) {
        // 화면이 사라질 때 마이페이지에 nil 전달
        // 이유: 마이페이지에서 어떤 값을 전달받아도 TabBar를 보여주게 작동
        observer.notify(nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        // Network Check
        NetworkCheck.shared.startMonitoring(vc: self)
        
        if let nickname = preNickName {
            isNicknameValid(nickname: nickname)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
// MARK: - Set Views
extension ModifyProfileViewController {
    func setUpView() {
        self.view.addSubview(profileImage)
        self.view.addSubview(cameraButton)
        self.view.addSubview(nicknameLabel)
        self.view.addSubview(nameTextField)
        self.view.addSubview(completeButton)
        
        accessoryView.addSubview(completeKeyboardButton)
        
        if let image = self.preProfileImg {
            let processor = TintImageProcessor(tint: .black_5)
            self.profileImage.kf.setImage(with: URL(string: image), placeholder: UIImage(), options: [.processor(processor)])
        }
        nameTextField.text = self.preNickName
    }
    func setUpConstraint() {
        profileImage.snp.makeConstraints { make in
            make.width.height.equalTo(106)
            make.centerX.equalToSuperview()
            make.top.equalTo(navigationView.snp.bottom).offset(45)
        }
        cameraButton.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(26.67)
            make.trailing.bottom.equalTo(profileImage)
        }
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(16)
        }
        nameTextField.snp.makeConstraints { make in
            make.height.equalTo(42)
            make.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }
        completeButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-34)
        }
        completeKeyboardButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
    }
}
// MARK: Set Targets
extension ModifyProfileViewController {
    func setTarget() {
        self.profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goAlbumImageDidTap)))
        self.cameraButton.addTarget(self, action: #selector(goAlbumButtonDidTap), for: .touchUpInside)
        self.nameTextField.addTarget(self, action: #selector(nameTextFieldEditingChanged(_:)), for: .editingChanged)
        self.completeButton.addTarget(self, action: #selector(completeButtonDidTap), for: .touchUpInside)
        self.completeKeyboardButton.addTarget(self, action: #selector(completeButtonDidTap), for: .touchUpInside)
    }
    @objc func nameTextFieldEditingChanged(_ sender: UITextField) {
        let text = sender.text ?? ""
        self.nickname = text
        isNicknameValid(nickname: self.nickname!)
    }
    // 닉네임 유효성 검사
    func isNicknameValid(nickname: String) {
        nickname.isEmpty ? completeButton.inactivateButton() : completeButton.activateButton()
        nickname.isEmpty ? completeKeyboardButton.inactivateButton() : completeKeyboardButton.activateButton()
    }
    // 앨범에서 사진/동영상 선택
    // 프로필 이미지 클릭 시
    @objc func goAlbumImageDidTap(sender: UITapGestureRecognizer) {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
        UIDevice.vibrate()
    }
    // 카메라 클릭 시
    @objc func goAlbumButtonDidTap() {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
        UIDevice.vibrate()
    }
    @objc func completeButtonDidTap() {
        
        UIDevice.vibrate()
        
        completeButton.startLoadingAnimation()
        completeKeyboardButton.startLoadingAnimation()
        
        // 이미지와 닉네임 둘 다 변경사항이 없을 때, selectedPhoto와 nickname 값이 nil이 되어 버그.
        // 예외처리
        if self.selectedPhoto == nil && self.nickname == nil {
            self.navigationController?.popViewController(animated: true)
            return
        }
        // 변경사항이 하나라도 있을 때 통신
        let moyaProfileInput = MoyaProfileInput(photo: self.selectedPhoto, nickname: self.nickname)
        self.modifyProfileWithMoya(model: moyaProfileInput)
        
    }
}
// MARK: - ImagePicker Delegate
extension ModifyProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.selectedPhoto = UIImage()
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.selectedPhoto = image
            self.profileImage.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
}
// MARK: - Textfield delegate
extension ModifyProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.view.bounds.origin.y = 0.0
        return true
    }
}
// MARK: - API Success
extension ModifyProfileViewController {
    // MARK: 프로필 편집 API
    func modifyProfileWithMoya(model: MoyaProfileInput) {
        UserService.shared.modifyProfile(model: model) { result in
            switch result {
                case .success(let data):
                    if data.success {
                        print("프로필 업데이트 성공 by moya:", data.message)
                        // 마이페이지에 노티를 준다.
                        self.observer.notify(.profileModified)
                        self.navigationController?.popViewController(animated: true)
                    }
                    break
            case .failure(let error):
                self.navigationController?.popViewController(animated: true)
                print("moya profile modify error", error.localizedDescription)
            default:
                print("default error")
                break
            }
        }
    }
}
