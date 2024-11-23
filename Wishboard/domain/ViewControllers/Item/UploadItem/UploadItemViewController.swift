//
//  UploadItemViewController.swift
//  Wishboard
//
//  Created by gomin on 2022/09/15.
//

import UIKit
import MaterialComponents.MaterialBottomSheet
import Lottie

class UploadItemViewController: UIViewController, Observer {
    var itemLinkObserver = ItemLinkObserver.shared
    
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
    // keyboard
    var restoreFrameValue: CGFloat = 0.0
    var preKeyboardHeight: CGFloat = 0.0
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.view.backgroundColor = .white
        self.tabBarController?.view.backgroundColor = .white
        
        // keyboard
        self.restoreFrameValue = self.view.frame.origin.y
        
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        setUploadItemView()
        
        // Observer init
        itemLinkObserver.bind(self)
        
        if !isUploadItem {
            self.tabBarController?.tabBar.isHidden = true
            self.wishListData = self.wishListModifyData
        } else {
            self.tabBarController?.tabBar.isHidden = false
            self.wishListData = WishListModel(folder_id: nil, folder_name: nil, item_id: nil, item_img_url: nil, item_name: nil, item_price: "0", item_url: "", item_memo: "", create_at: nil, item_notification_type: nil, item_notification_date: nil, cart_state: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.addKeyboardNotifications()
        // Network Check
        NetworkCheck.shared.startMonitoring(vc: self)
        // 수정화면 초기 진입 시에는 상단 BackButton 활성화
        self.activateButtons()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardNotifications()
        // 화면 disappear 시 스핀 로딩 버튼도 제거
        self.uploadItemView.saveButton.stopLoadingAnimation()
    }
    
    private func activateButtons() {
        DispatchQueue.main.async {
            self.uploadItemView.backButton.isEnabled = true
            self.uploadItemView.uploadImageTableView.isUserInteractionEnabled = true
            self.uploadItemView.uploadContentTableView.isUserInteractionEnabled = true
        }
    }
    private func inActivateButtons() {
        DispatchQueue.main.async {
            self.uploadItemView.backButton.isEnabled = false
            self.uploadItemView.uploadImageTableView.isUserInteractionEnabled = false
            self.uploadItemView.uploadContentTableView.isUserInteractionEnabled = false
        }
    }
    
    @objc func goBack() {
        UIDevice.vibrate()
        self.navigationController?.popViewController(animated: true)
    }
    @objc func MyTapMethod(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    /// Observer method
    func update(_ newValue: Any) {
        let data = newValue as? ItemParseData
        switch data?.usecase {
        case .itemLinkExit:
            setPageContents()
        case .itemParsingFail:
            wishListData.item_url = ""
            SnackBar.shared.showSnackBar(self, message: .failShoppingLink)
            setPageContents()
        case .itemParsingSuccess:
            // 파싱한 아이템 정보 적용
            wishListData.item_url = data?.itemModel?.link
            wishListData.item_name = data?.itemModel?.itemName
            wishListData.item_price = data?.itemModel?.itemPrice
            wishListData.item_img_url = data?.itemModel?.imageURL
            selectedImage = nil
            // 테이블뷰 reload
            let indexPath1 = IndexPath(row: 0, section: 0)
            let indexPath2 = IndexPath(row: 1, section: 0)
            let indexPath5 = IndexPath(row: 4, section: 0)
            uploadItemView.uploadImageTableView.reloadRows(at: [indexPath1], with: .automatic)
            uploadItemView.uploadContentTableView.reloadRows(at: [indexPath1, indexPath2, indexPath5], with: .automatic)
            isValidContent()
            
            setPageContents()
        default:
            print("Item Parse Error")
        }
    }
    /// 키보드가 올라와있고 화면이 위로 스크롤 되어있었다면 제자리로 두기
    func setPageContents() {
        view.endEditing(true)
        view.frame.origin.y = 0.0
        preKeyboardHeight = 0.0
    }
}
// MARK: - TableView delegate
extension UploadItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == uploadItemView.uploadImageTableView {return 1}
        else {return 6}
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == uploadItemView.uploadImageTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UploadItemPhotoTableViewCell", for: indexPath) as? UploadItemPhotoTableViewCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            // 만약 아이템 수정이라면 기존 이미지 출력
            if !isUploadItem {
                if let itemImageURL = self.wishListData.item_img_url {
                    cell.setUpImage(itemImageURL)
                } else {
                    cell.photoImage.image = UIImage()
                }
            } else { // 링크로 아이템 불러온 경우라면
                if let itemImageURL = self.wishListData.item_img_url {
                    cell.setUpImage(itemImageURL)
                } else { // 만약 새로 아이템을 추가하는 경우라면
                    cell.photoImage.image = nil
                }
            }
            // 새로 사진을 선택했다면
            if self.selectedImage != nil {
                cell.setUpImage(self.selectedImage)
            }
            
            return cell
        } else {
            let tag = indexPath.row
            // TextField가 있는 Cell
            switch tag {
            case 0, 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "UploadItemTextfieldTableViewCell", for: indexPath) as? UploadItemTextfieldTableViewCell else { return UITableViewCell() }
                cell.setTextfieldCell(dataSourceDelegate: self)
                cell.setPlaceholder(tag: tag)
                if let cellData = self.wishListData {
                    cell.setUpData(tag: tag, data: cellData)
                }
                if tag == 0 {cell.textfield.addTarget(self, action: #selector(itemNameTextfieldEditingField(_:)), for: .editingChanged)}
                else if tag == 1 {
                    cell.textfield.addTarget(self, action: #selector(itemPriceTextfieldEditingField(_:)), for: .editingChanged)
                }
                cell.selectionStyle = .none
                return cell
            case 2, 3, 4:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "UploadItemBottomSheetTableViewCell", for: indexPath) as? UploadItemBottomSheetTableViewCell else { return UITableViewCell() }
                cell.setBottomSheetCell(isUploadItem: self.isUploadItem, tag: tag)
                if let cellData = self.wishListData {
                    cell.setUpData(isUploadItem: self.isUploadItem, tag: tag, data: cellData)
                }
                cell.selectionStyle = .none
                return cell
            case 5:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "UploadItemTextViewCell", for: indexPath) as? UploadItemTextViewCell else { return UITableViewCell() }
                
                if isUploadItem {
                    cell.memoTextView.text = Placeholder.uploadItemMemo
                    cell.memoTextView.textColor = .placeholderText
                } else if let cellData = self.wishListData {
                    cell.setUpData(data: cellData)
                }
                
                cell.memoTextView.delegate = self
                cell.selectionStyle = .none
                return cell
            default:
                fatalError()
            }
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == uploadItemView.uploadImageTableView { return 251 }
        else {
            if indexPath.row == 5 {
                return 200
            } else {
                return 54
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIDevice.vibrate()
        
        if tableView == uploadItemView.uploadImageTableView {
            // '사진 찍기' '사진 보관함' 팝업창
            alertCameraMenu()
        } else {
            let tag = indexPath.row
            switch tag {
            // 폴더 설정 BottomSheet
            case 2:
                showFolderBottomSheet()
            // 알람 설정 BottomSheet
            case 3:
                showNotificationBottomSheet()
            // 쇼핑몰 링크 BottomSheet
            case 4:
                showLinkBottomSheet()
            default:
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
// MARK: - Functions
extension UploadItemViewController {
    func setUploadItemView() {
        uploadItemView = UploadItemView()
        uploadItemView.saveButton = LoadingButton(Button.save, self).then{
            $0.activateButton()
            $0.layer.cornerRadius = 15
            $0.titleLabel?.setTypoStyleWithSingleLine(typoStyle: .SuitB3)
        }
        
        uploadItemView.setImageTableView(dataSourceDelegate: self)
        uploadItemView.setContentTableView(dataSourceDelegate: self)
        uploadItemView.setUpView()
        uploadItemView.setUpConstraint()
        
        self.view.addSubview(uploadItemView)
        uploadItemView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        uploadItemView.uploadImageTableView.keyboardDismissMode = .onDrag
        uploadItemView.uploadContentTableView.keyboardDismissMode = .onDrag
        
        if isUploadItem {
            self.tabBarController?.tabBar.isHidden = false
            uploadItemView.backButton.isHidden = true
            uploadItemView.pageTitle.text = Title.addItem
            uploadItemView.saveButton.addTarget(self, action: #selector(saveButtonDidTap), for: .touchUpInside)
            uploadItemView.setSaveButton(false)
        } else {
            self.tabBarController?.tabBar.isHidden = true
            uploadItemView.backButton.isHidden = false
            uploadItemView.pageTitle.text = Title.modifyItem
            uploadItemView.backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
            uploadItemView.saveButton.addTarget(self, action: #selector(modifyButtonDidTap), for: .touchUpInside)
            uploadItemView.setSaveButton(true)
        }
        // BottomSheet 객체 선언
        foldervc =  SetFolderBottomSheetViewController()
        linkvc = ShoppingLinkViewController()
        notivc = NotificationSettingViewController()
        
        // 화면 터치 시 키보드 내리기
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        uploadItemView.scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        uploadItemView.scrollView.delegate = self
    }
    // MARK: - 저장 버튼 클릭 시 (아이템 추가)
    @objc func saveButtonDidTap() {
        UIDevice.vibrate()
        
        // 서버 통신 와중에는 버튼 및 화면 탭 비활성화
        self.inActivateButtons()
        
        uploadItemView.saveButton.startLoadingAnimation()
        uploadItemView.saveButton.titleLabel?.isHidden = false
        uploadItemView.saveButton.titleLabel?.alpha = 1
        
        let data = self.wishListData
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 이미지 uri를 UIImage로 변환
            var selectedImage : UIImage?
            if self.selectedImage == nil {
                if let imageUrl = data?.item_img_url {
                    let url = URL(string: imageUrl)
                    guard let url = url else {return}
                    guard let imgData = try? Data(contentsOf: url) else {return}
                    selectedImage = UIImage(data: imgData)
                }
            } else {selectedImage = self.selectedImage}
           
            let moyaItemInput = MoyaItemInput(folderId: data?.folder_id,
                                              photo: selectedImage ?? UIImage(),
                                              itemName: data?.item_name ?? "",
                                              itemPrice: data?.item_price ?? "",
                                              itemURL: data?.item_url,
                                              itemMemo: data?.item_memo,
                                              itemNotificationType: data?.item_notification_type,
                                              itemNotificationDate: data?.item_notification_date)
            self.uploadItemWithMoya(model: moyaItemInput)
        }
    }
    // MARK: 저장 버튼 클릭 시 (아이템 수정)
    @objc func modifyButtonDidTap() {
        UIDevice.vibrate()
        
        // 서버 통신 와중에는 버튼 및 화면 탭 비활성화
        self.inActivateButtons()
        
        uploadItemView.saveButton.startLoadingAnimation()
        uploadItemView.saveButton.titleLabel?.isHidden = false
        uploadItemView.saveButton.titleLabel?.alpha = 1
        
        let data = self.wishListData
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 이미지 uri를 UIImage로 변환
            var selectedImage : UIImage?
            if let imageUrl = data?.item_img_url {
                let url = URL(string: imageUrl)
                guard let url = url else {return}
                guard let imgData = try? Data(contentsOf: url) else {return}
                selectedImage = UIImage(data: imgData)
            }
            if self.selectedImage != nil {selectedImage = self.selectedImage}
            
            let moyaItemInput = MoyaItemInput(folderId: data?.folder_id,
                                              photo: selectedImage ?? UIImage(),
                                              itemName: data?.item_name ?? "",
                                              itemPrice: data?.item_price ?? "",
                                              itemURL: data?.item_url,
                                              itemMemo: data?.item_memo,
                                              itemNotificationType: data?.item_notification_type,
                                              itemNotificationDate: data?.item_notification_date)
            self.modifyItemWithMoya(model: moyaItemInput, id: data?.item_id ?? -1)
            print("✅ modify item -> \(moyaItemInput)")
        }
    }
}
// MARK: - Cell set & Actions
extension UploadItemViewController {
    
    // Actions
    @objc func itemNameTextfieldEditingField(_ sender: UITextField) {
        let text = sender.text ?? ""
        self.wishListData.item_name = text
        isValidContent()
    }
    @objc func itemPriceTextfieldEditingField(_ sender: UITextField) {
        let text = sender.text ?? ""
        self.wishListData.item_price = setPriceString(text)
        if let priceStr = self.wishListData.item_price {
            isValidContent()
            guard let price = Float(priceStr) else {return}
            sender.text = numberFormatter.string(from: NSNumber(value: price))
        }
    }
    func setPriceString(_ str: String) -> String {
        let myString = str.replacingOccurrences(of: ",", with: "")
        return myString
    }
    // 상품명, 가격 입력 여부에 따른 저장버튼 활성화 설정
    func isValidContent() {
        var isItemNameValid: Bool = false
        var isItemPriceValid: Bool = false
        
        let isImageSelected = self.selectedImage != nil
        
        if let itemName = self.wishListData.item_name {
            isItemNameValid = !(itemName.isEmpty)
        }
        if let itemPrice = self.wishListData.item_price {
            isItemPriceValid = !(itemPrice.isEmpty)
        }
        
        let saveButtonEnabled = isImageSelected && isItemNameValid && isItemPriceValid
        self.uploadItemView.setSaveButton(saveButtonEnabled)
    }
    // '사진 찍기' '사진 보관함' 팝업창
    func alertCameraMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cameraAction =  UIAlertAction(title: Title.camera, style: UIAlertAction.Style.default){(_) in
            let camera = UIImagePickerController()
            camera.sourceType = .camera
            camera.allowsEditing = true
            camera.cameraDevice = .rear
            camera.cameraCaptureMode = .photo
            camera.delegate = self
            self.present(camera, animated: true, completion: nil)
        }
        let albumAction =  UIAlertAction(title: Title.album, style: UIAlertAction.Style.default){(_) in
            let album = UIImagePickerController()
            album.delegate = self
            album.sourceType = .photoLibrary
            self.present(album, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: Title.cancel, style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.view.tintColor = .gray_700
        alert.addAction(cameraAction)
        alert.addAction(albumAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true)
    }
    // 폴더 설정 BottomSheet
    func showFolderBottomSheet() {
        foldervc.setPreViewController(self)
        if !isUploadItem {
            foldervc.selectedFolderId = self.wishListData.folder_id
            foldervc.selectedFolder = self.wishListData.folder_name
        }
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
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: linkvc)
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 317
        bottomSheet.dismissOnDraggingDownSheet = false
        
        self.present(bottomSheet, animated: true, completion: nil)
    }
}
// MARK: - ImagePicker Delegate
extension UploadItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 앨범에서 사진 선택 시
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.selectedImage = image
            isValidContent()
            
            self.uploadItemView.uploadImageTableView.reloadData()
        }
        // 카메라에서 사진 찍은 경우
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            self.selectedImage = image
            isValidContent()
            
            self.uploadItemView.uploadImageTableView.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
// MARK: - ScrollView Delegate
extension UploadItemViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        self.view.frame.origin.y = restoreFrameValue
        self.preKeyboardHeight = 0.0
        self.view.endEditing(true)
    }
}
// MARK: - API Success
extension UploadItemViewController {
    // MARK: 아이템 추가 API
    func uploadItemWithMoya(model: MoyaItemInput) {
        ItemService.shared.uploadItem(model: model) { result in
            // 서버 통신 이후에는 버튼 및 화면 탭 활성화
            self.activateButtons()
            self.uploadItemView.saveButton.stopLoadingAnimation()
            
            switch result {
                case .success(let data):
                    if data.success {
                        print("아이템 등록 성공 by moya:", data.message)
                        self.uploadItemView.saveButton.stopLoadingAnimation()
                        self.viewDidLoad()
                        // 홈화면으로 이동
                        ScreenManager.shared.goMain()
                        WishItemObserver.shared.notify(.upload)
                    }
                    break
            case .failure(let error):
                self.viewDidLoad()
                // 홈화면으로 이동
                ScreenManager.shared.goMain()
                print("moya item upload error", error.localizedDescription)
            default:
                print("default error")
                break
            }
        }
    }
    // MARK: 아이템 수정 API
    func modifyItemWithMoya(model: MoyaItemInput, id: Int) {
        ItemService.shared.modifyItem(model: model, id: id) { result in
            // 서버 통신 이후에는 버튼 및 화면 탭 활성화
            self.activateButtons()
            self.uploadItemView.saveButton.stopLoadingAnimation()
            
            switch result {
                case .success(let data):
                    if data.success {
                        print("아이템 수정 성공 by moya:", data.message)
                        self.uploadItemView.saveButton.stopLoadingAnimation()
                        self.viewDidLoad()
                        // 뒤로 화면 이동 (아이템 상세 조회 화면)
                        WishItemObserver.shared.notify(.modify)
                        self.navigationController?.popViewController(animated: true)
                    }
                    break
            case .failure(let error):
                self.viewDidLoad()
                self.navigationController?.popViewController(animated: true)
                print("moya item modify error", error.localizedDescription)
            default:
                print("default error")
                break
            }
        }
    }
}
// MARK: - TextField & Keyboard Methods
extension UploadItemViewController: UITextFieldDelegate {
    func addKeyboardNotifications() {
        // 키보드가 나타날 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillAppear(noti:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillDisappear(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func removeKeyboardNotifications() {
        // 키보드가 나타날 때 앱에게 알리는 메서드 제거
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 제거
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillAppear(noti: NSNotification) {
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            print("pre:", preKeyboardHeight, "curr:", keyboardHeight)
            if preKeyboardHeight < keyboardHeight {
                let dif = keyboardHeight - preKeyboardHeight
                self.view.frame.origin.y -= dif / 1.2
                preKeyboardHeight = keyboardHeight
            } else if preKeyboardHeight > keyboardHeight {
                let dif = preKeyboardHeight - keyboardHeight
                self.view.frame.origin.y += dif / 1.2
                preKeyboardHeight = keyboardHeight
            }
        }
        print("keyboard Will appear Execute")
    }
    
    @objc func keyboardWillDisappear(noti: NSNotification) {
        if self.view.frame.origin.y != restoreFrameValue {
            if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
//                self.view.frame.origin.y += keyboardHeight
            }
            print("keyboard Will Disappear Execute")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.frame.origin.y = restoreFrameValue
        self.preKeyboardHeight = 0.0
        print("touches Began Execute")
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn Execute")
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing Execute")
        self.preKeyboardHeight = 0.0
        self.view.frame.origin.y = self.restoreFrameValue
        return true
    }
    
}

// MARK: - TextView delegate
extension UploadItemViewController: UITextViewDelegate {
    // 텍스트뷰에서 텍스트 편집이 시작될 때 호출되는 메서드
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Placeholder.uploadItemMemo {
            textView.text = ""
            textView.textColor = UIColor.gray_700
        }
    }

    // 텍스트뷰에서 텍스트 편집이 종료될 때 호출되는 메서드
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Placeholder.uploadItemMemo
            textView.textColor = UIColor.placeholderText
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        self.wishListData.item_memo = text
        
        // 최소 높이를 유지하도록 높이를 조절
        let newHeight = max(200, textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude)).height)
        if newHeight > 200 {
            // TODO: TextView Height 동적
            
        }
        updateCellHeight()
    }
    
    private func updateCellHeight() {
        self.uploadItemView.uploadContentTableView.beginUpdates()
        self.uploadItemView.uploadContentTableView.endUpdates()
   }
}
