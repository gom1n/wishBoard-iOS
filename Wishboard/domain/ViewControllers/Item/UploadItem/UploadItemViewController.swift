//
//  UploadItemViewController.swift
//  Wishboard
//
//  Created by gomin on 2022/09/15.
//

import UIKit
import MaterialComponents.MaterialBottomSheet

class UploadItemViewController: UIViewController {
    // MARK: - Properties
    var uploadItemView: UploadItemView!
    let cellTitleArray = ["상품명(필수)", "₩ 가격(필수)", "폴더", "상품 일정 알림", "쇼핑몰 링크", "브랜드, 사이즈, 컬러 등 아이템 정보를 메모로 남겨보세요!😉"]
    var numberFormatter: NumberFormatter!
    var selectedImage: UIImage!
    // Bottom Sheets
    var foldervc: SetFolderBottomSheetViewController!
    var notivc: NotificationSettingViewController!
    var linkvc: ShoppingLinkViewController!
    // Modify Item
    var isUploadItem: Bool!
    var wishListModifyData: WishListModel!
    // UploadItem
    var wishListData: WishListModel!
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.navigationController?.isNavigationBarHidden = true
        
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        setUploadItemView()
        
        if !isUploadItem {
            self.wishListData = self.wishListModifyData
        }
    }
    @objc func goBack() {
        self.dismiss(animated: true)
    }
}
// MARK: - TableView delegate
extension UploadItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tag = indexPath.row
        // 사진 선택 Cell
        if tag == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UploadItemPhotoTableViewCell", for: indexPath) as? UploadItemPhotoTableViewCell else { return UITableViewCell() }
            
            // 만약 아이템 수정이라면 기존 이미지 출력
            if !isUploadItem {
                if let itemImageURL = self.wishListData.item_img_url {
                    cell.setUpImage(itemImageURL)
                }
            } else {    // 만약 새로 아이템을 추가하는 경우라면
                cell.photoImage.image = UIImage()
                cell.cameraImage.isHidden = false
            }
            // 새로 사진을 선택했다면
            if self.selectedImage != nil {
                cell.setUpImage(self.selectedImage)
            }
            
            return cell
        } else {
            let cell = UITableViewCell()
            // TextField가 있는 Cell
            if tag == 1 || tag == 2 || tag == 6 {setTextFieldCell(cell, tag)}
            // 클릭 시 bottomSheet 올라오는 Cell
            if tag == 3 || tag == 4 || tag == 5 {setSelectCell(cell, tag)}
            
            cell.selectionStyle = .none
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tag = indexPath.row
        switch tag {
        case 0:
            return 251
        default:
            return 54
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = indexPath.row
        switch tag {
        // '사진 찍기' '사진 보관함' 팝업창
        case 0:
            alertCameraMenu()
        // 폴더 설정 BottomSheet
        case 3:
            showFolderBottomSheet()
        // 알람 설정 BottomSheet
        case 4:
            showNotificationBottomSheet()
        // 쇼핑몰 링크 BottomSheet
        case 5:
            showLinkBottomSheet()
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
// MARK: - Functions
extension UploadItemViewController {
    func setUploadItemView() {
        uploadItemView = UploadItemView()
        uploadItemView.setTableView(dataSourceDelegate: self)
        uploadItemView.setUpView()
        uploadItemView.setUpConstraint()
        
        self.view.addSubview(uploadItemView)
        uploadItemView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        uploadItemView.backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        if isUploadItem {
            uploadItemView.backButton.isHidden = true
            uploadItemView.pageTitle.text = "아이템 추가"
            uploadItemView.saveButton.addTarget(self, action: #selector(saveButtonDidTap), for: .touchUpInside)
            uploadItemView.setSaveButton(false)
        } else {
            uploadItemView.backButton.isHidden = false
            uploadItemView.pageTitle.text = "아이템 수정"
            uploadItemView.saveButton.addTarget(self, action: #selector(modifyButtonDidTap), for: .touchUpInside)
            uploadItemView.setSaveButton(true)
        }
        // BottomSheet 객체 선언
        foldervc =  SetFolderBottomSheetViewController()
        linkvc = ShoppingLinkViewController()
        notivc = NotificationSettingViewController()
    }
    @objc func saveButtonDidTap() {
        let lottieView = uploadItemView.saveButton.setSpinLottieView(uploadItemView.saveButton)
        uploadItemView.saveButton.isSelected = true
        lottieView.isHidden = false
        lottieView.loopMode = .repeat(2) // 2번 반복
        lottieView.play { completion in
            ScreenManager().goMainPages(0, self)
            SnackBar(self, message: .addItem)
        }
    }
    @objc func modifyButtonDidTap() {
        let lottieView = uploadItemView.saveButton.setSpinLottieView(uploadItemView.saveButton)
        uploadItemView.saveButton.isSelected = true
        lottieView.isHidden = false
        lottieView.loopMode = .repeat(2) // 2번 반복
        lottieView.play { completion in
            self.dismiss(animated: true)
            SnackBar(self, message: .modifyItem)
        }
    }
}
// MARK: - Cell set & Actions
extension UploadItemViewController {
    // 클릭 시 bottomSheet 올라오는 Cell
    func setSelectCell(_ cell: UITableViewCell, _ tag: Int) {
        // 만약 아이템 수정이라면
        if !isUploadItem {
            switch tag {
            case 3:
                if let folder = self.wishListData.folder_name {cell.textLabel?.text = folder}
                else {cell.textLabel?.text = cellTitleArray[tag - 1]}
            case 4:
                if let notiType = self.wishListData.item_notification_type {
                    cell.textLabel?.text = "[" + notiType + "] " + FormatManager().notiDateToKoreanStr(self.wishListData.item_notification_date!)!
                }
                else {cell.textLabel?.text = cellTitleArray[tag - 1]}
            case 5:
                if let link = self.wishListData.item_url {
                    if link != "" {cell.textLabel?.text = link}
                    else {cell.textLabel?.text = cellTitleArray[tag - 1]}
                }
                else {cell.textLabel?.text = cellTitleArray[tag - 1]}
            default:
                fatalError()
            }
        } else {
            // 새로 아이템 추가하는 경우라면 placeHolder 초기설정
            cell.textLabel?.text = cellTitleArray[tag - 1]
        }
        cell.textLabel?.font = UIFont.Suit(size: 14, family: .Regular)
        
        let arrowImg = UIImageView().then{
            $0.image = UIImage(named: "arrow_right")
        }
        cell.contentView.addSubview(arrowImg)
        arrowImg.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        // 쇼핑몰 링크 입력 셀
        if tag == 5 {
            let subTitle = UILabel().then{
                $0.text = "복사한 링크로 아이템 정보를 불러올 수 있어요!"
                $0.font = UIFont.Suit(size: 10, family: .Regular)
                $0.textColor = .wishboardGreen
            }
            cell.contentView.addSubview(subTitle)
            subTitle.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalTo(arrowImg.snp.leading)
            }
            // 만약 쇼핑몰 링크를 수정했다면 업데이트
            if let link = linkvc.link {
                cell.textLabel?.text = link
                subTitle.isHidden = true
            }
        }
        // 만약 알림 날짜를 재설정했다면 업데이트
        if let type = notivc.notiType {
            if let dateTime = notivc.dateAndTime {
                if tag == 4 {cell.textLabel?.text = "[" + type + "] " + dateTime}
                self.wishListData.item_notification_type = type
                self.wishListData.item_notification_date = FormatManager().koreanStrToDate(dateTime)
            }
        }
        // 만약 폴더를 재선택했다면 업데이트
        if let selectedFolder = foldervc.selectedFolder {
            if tag == 3 {cell.textLabel?.text = selectedFolder}
        }
    }
    // TextField가 있는 Cell
    func setTextFieldCell(_ cell: UITableViewCell, _ tag: Int) {
        let textfield = UITextField().then{
            $0.backgroundColor = .clear
            $0.placeholder = self.cellTitleArray[tag - 1]
            $0.font = UIFont.Suit(size: 14, family: .Regular)
            $0.addLeftPadding(16)
        }
        cell.contentView.addSubview(textfield)
        textfield.snp.makeConstraints { make in
            make.leading.top.bottom.trailing.equalToSuperview()
        }
        // Add target
        switch tag {
        case 1:
            if let data = self.wishListData {textfield.text = data.item_name}
            textfield.addTarget(self, action: #selector(itemNameTextfieldEditingField(_:)), for: .editingChanged)
        case 2:
            if let data = self.wishListData {
                textfield.text = numberFormatter.string(from: NSNumber(value: Int(data.item_price!)!))
            }
            textfield.addTarget(self, action: #selector(itemPriceTextfieldEditingField(_:)), for: .editingChanged)
        default:
            if let data = self.wishListData {textfield.text = data.item_memo}
            textfield.addTarget(self, action: #selector(memoTextfieldEditingField(_:)), for: .editingChanged)
        }
        
    }
    // Actions
    @objc func itemNameTextfieldEditingField(_ sender: UITextField) {
        let text = sender.text!
        self.wishListData.item_name = text
        isValidContent()
    }
    @objc func itemPriceTextfieldEditingField(_ sender: UITextField) {
        let text = sender.text ?? ""
        self.wishListData.item_price = setPriceString(text)
        guard let price = Float(text) else {return} //
        sender.text = numberFormatter.string(from: NSNumber(value: price))
        isValidContent()
    }
    @objc func memoTextfieldEditingField(_ sender: UITextField) {
        let text = sender.text!
        self.wishListData.item_memo = text
    }
    func setPriceString(_ str: String) -> String {
        let myString = str.replacingOccurrences(of: ",", with: "")
        return myString
    }
    // 상품명, 가격 입력 여부에 따른 저장버튼 활성화 설정
    func isValidContent() {
        guard let iN = self.wishListData.item_name else {return}
        guard let iP = self.wishListData.item_price else {return}
        guard let iI = self.selectedImage else {return}
        
        if (iN != "") && (iP != "") && (iI != nil) {uploadItemView.setSaveButton(true)}
        else {uploadItemView.setSaveButton(false)}
    }
    // '사진 찍기' '사진 보관함' 팝업창
    func alertCameraMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cameraAction =  UIAlertAction(title: "사진 찍기", style: UIAlertAction.Style.default){(_) in
            let camera = UIImagePickerController()
            camera.sourceType = .camera
            camera.allowsEditing = true
            camera.cameraDevice = .rear
            camera.cameraCaptureMode = .photo
            camera.delegate = self
            self.present(camera, animated: true, completion: nil)
        }
        let albumAction =  UIAlertAction(title: "사진 보관함", style: UIAlertAction.Style.default){(_) in
            let album = UIImagePickerController()
            album.delegate = self
            album.sourceType = .photoLibrary
            self.present(album, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.view.tintColor = .black
        alert.addAction(cameraAction)
        alert.addAction(albumAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true)
    }
    // 폴더 설정 BottomSheet
    func showFolderBottomSheet() {
        foldervc.setPreViewController(self)
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: foldervc)
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 317
        bottomSheet.dismissOnDraggingDownSheet = false
        
        self.present(bottomSheet, animated: true, completion: nil)
    }
    // 알람 설정 BottomSheet
    func showNotificationBottomSheet() {
        notivc.setPreViewController(self)
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: notivc)
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 317
        bottomSheet.dismissOnDraggingDownSheet = false
        
        self.present(bottomSheet, animated: true, completion: nil)
    }
    // 쇼핑몰 링크 BottomSheet
    func showLinkBottomSheet() {
        linkvc.setPreViewController(self)
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: linkvc)
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 317
        bottomSheet.dismissOnDraggingDownSheet = false
        
        self.present(bottomSheet, animated: true, completion: nil)
    }
}
// MARK: - ImagePicker Delegate
extension UploadItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
//            self.selectedImage = image
//            self.uploadItemView.uploadItemTableView.reloadData()
//        }
        // 앨범에서 사진 선택 시
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.selectedImage = image
            isValidContent()
            
            // 첫번째 셀만 reload
            let indexPath = IndexPath(row: 0, section: 0)
            self.uploadItemView.uploadItemTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
