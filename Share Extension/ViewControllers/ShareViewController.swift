//
//  ShareViewController.swift
//  Share Extension
//
//  Created by gomin on 2022/09/25.
//

import UIKit
import Social
import SnapKit
import Then
import MaterialComponents.MaterialBottomSheet
import Lottie
import MobileCoreServices

class ShareViewController: UIViewController {
    //MARK: - Properties
    var shareView: ShareView!
    var folderListData: [FolderListModel] = []
    var notivc: NotificationSettingViewController!
    var newFoldervc: NewFolderViewController!
    
    var selectedFolder: String?
    var selectedFolderIdx: Int?
    
    // Item Contents
    var webURL: String?
    var itemImg: String?
    var itemName: String?
    var itemPrice: String?
    var notificationType: String?
    var notificationDate: String?
    
    var numberFormatter: NumberFormatter!
    // keyboard
    var restoreFrameValue: CGFloat = 0.0
    var preKeyboardHeight: CGFloat = 0.0
    
    //MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        // keyboard
        self.restoreFrameValue = self.view.frame.origin.y
        // itemPrice numberFormat
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        self.selectedFolderIdx = -1
        setUpShareView()
    }
    override func viewDidAppear(_ animated: Bool) {
        // Network Check
        NetworkCheck.shared.startMonitoring(vc: self)
        // Login Check
        let defaults = UserDefaults(suiteName: "group.gomin.Wishboard.Share")
        let token = defaults?.string(forKey: "accessToken") ?? ""
        if token == "" {
            needLogin()
            return
        } else {
            DispatchQueue.main.async {
                self.getWebURL()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.addKeyboardNotifications()
        // Network Check
        NetworkCheck.shared.startMonitoring(vc: self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardNotifications()
    }
    //MARK: - Functions
    func setUpShareView() {
        // Set Views & Constraints
        shareView = ShareView()
        self.view.addSubview(shareView)
        shareView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        shareView.setUpCollectionView(dataSourceDelegate: self)
        shareView.setUpView()
        shareView.setUpConstraint()
        // Set BottomSheets
        notivc = NotificationSettingViewController()
        newFoldervc = NewFolderViewController()
        // Add Targets
        shareView.itemNameTextField.addTarget(self, action: #selector(itemNameTextFieldEditingChanged(_:)), for: .editingChanged)
        shareView.itemPriceTextField.addTarget(self, action: #selector(itemPriceTextFieldEditingChanged(_:)), for: .editingChanged)
        shareView.quitButton.addTarget(self, action: #selector(quit), for: .touchUpInside)
        shareView.completeButton.addTarget(self, action: #selector(completeButtonDidTap), for: .touchUpInside)
        shareView.setNotificationButton.addTarget(self, action: #selector(showNotificationBottomSheet), for: .touchUpInside)
        shareView.addFolderButton.addTarget(self, action: #selector(showAddNewFolderBottomSheet), for: .touchUpInside)
    }
    func getWebURL() {
        let extensionItems = extensionContext?.inputItems as! [NSExtensionItem]
        for items in extensionItems{
           if let itemProviders = items.attachments {
               for item_provider in itemProviders {
                   //URL 데이터를 가지고 있는가?
                   if item_provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                       item_provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil)
                        { (data, error) in
                               print("URL : \(data)")
                            self.webURL = (data as! NSURL).absoluteString!
                            ShareDataManager().getItemDataDataManager((data as! NSURL).absoluteString!, self)
                        }
                   }
               }
           }
        }
    }
    // MARK: - Actions
    // 상품명 편집
    @objc func itemNameTextFieldEditingChanged(_ sender: UITextField) {
        let text = sender.text ?? ""
        self.itemName = text
//        print(self.itemName)
        setButton()
    }
    // 상품가격 편집
    @objc func itemPriceTextFieldEditingChanged(_ sender: UITextField) {
        let text = sender.text ?? ""
        self.itemPrice = setPriceString(text)
        if let priceStr = self.itemPrice {
            if priceStr != "" {
                guard let price = Float(priceStr) else {return}
                sender.text = numberFormatter.string(from: NSNumber(value: price))
            } else { self.itemPrice = "" }
        }
        setButton()
    }
    func setPriceString(_ str: String) -> String {
        let myString = str.replacingOccurrences(of: ",", with: "")
        return myString
    }
    func isValidContent() -> Bool {
        if self.itemName != "" && self.itemPrice != ""
            && self.itemName != nil && self.itemPrice != nil
//            && self.itemImg != nil
            {return true}
        else {return false}
    }
    func setButton() {
        if isValidContent() {
            shareView.completeButton.activateButton()
        } else {
            shareView.completeButton.inactivateButton()
        }
    }
    // X버튼 클릭
    @objc func quit() {
        UIDevice.vibrate()
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    // 위시리스트 추가 버튼
    @objc func completeButtonDidTap() {
        UIDevice.vibrate()
       
        shareView.completeButton.startLoadingAnimation()
        
        // 만약 상품명 또는 가격이 비어있을 시
        if self.itemName == nil || self.itemPrice == nil {
            SnackBar.shared.showSnackBar(self, message: .emptyItemContent)
            return
        }
        
        // 이미지 uri를 UIImage로 변환
        var selectedImage : UIImage? = nil
        if let itemImg = self.itemImg {
            if let url = URL(string: itemImg), let data = try? Data(contentsOf: url) {
                selectedImage = UIImage(data: data)
            }
        }
//        guard let itemImg = self.itemImg else {return}
//        guard let url = URL(string: itemImg) else {return}
//        var selectedImage : UIImage?
//        guard let data = try? Data(contentsOf: url) else {return}
//        DispatchQueue.main.async { [self] in
//            selectedImage = UIImage(data: data)
            ShareDataManager().uploadItemDataManager(selectedFolderIdx, selectedImage, itemName!, itemPrice!, webURL!, "", notificationType, notificationDate, self)
//        }
    }
    // 알람 설정 BottomSheet
    @objc func showNotificationBottomSheet() {
        UIDevice.vibrate()
        notivc.setPreViewController(self)
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: notivc)
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 317
        bottomSheet.dismissOnDraggingDownSheet = false
        
        self.present(bottomSheet, animated: true, completion: nil)
    }
    // 새 폴더 추가 BottomSheet
    @objc func showAddNewFolderBottomSheet() {
        UIDevice.vibrate()
        newFoldervc.preVC = self
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: newFoldervc)
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 317
        bottomSheet.dismissOnDraggingDownSheet = false
        
        self.present(bottomSheet, animated: true, completion: nil)
    }
}
// MARK: - CollectionView delegate
extension ShareViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = folderListData.count ?? 0
        return count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCollectionViewCell.identifier,
                                                            for: indexPath)
                as? FolderCollectionViewCell else{ fatalError() }
        let itemIdx = indexPath.row
        cell.setUpData(self.folderListData[itemIdx])
        
        if let selectedFolderIdx = self.selectedFolderIdx {
            if selectedFolderIdx == self.folderListData[itemIdx].folder_id {
                cell.setSelectedFolder(true)
            } else if selectedFolderIdx == -1 && itemIdx == 0 {
                cell.setSelectedFolder(true)
                self.selectedFolderIdx = self.folderListData[itemIdx].folder_id
            } else {
                cell.setSelectedFolder(false)
            }
        } else {
            cell.setSelectedFolder(false)
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIDevice.vibrate()
        
        let itemIdx = indexPath.item
        guard let folderId = self.folderListData[itemIdx].folder_id else {return}
        if self.selectedFolderIdx == folderId {self.selectedFolderIdx = nil}
        else {self.selectedFolderIdx = folderId}
        
        reloadDataAnimation()
    }
}
// MARK: - API Success
extension ShareViewController {
    func needLogin() {
        shareView.completeButton.needLoginButton()
        shareView.itemNameTextField.isEnabled = false
        shareView.itemPriceTextField.isEnabled = false
        shareView.setNotificationButton.isEnabled = false
        shareView.addFolderButton.isEnabled = false
    }
    // MARK: 폴더 리스트 조회 API
    func getFolderListAPISuccess(_ result: [FolderListModel]) {
        print("폴더 가져오기 성공", result)
        self.folderListData = result
        self.selectedFolderIdx = -1
        reloadDataAnimation()
        
        shareView.completeButton.activateButton()
    }
    func getFolderListAPIFail() {
        FolderDataManager().getFolderListDataManager(self)
    }
    // MARK: 아이템 정보 파싱
    func getItemDataAPISuccess(_ result: APIModel<ItemParsingModel>) {
//        print("get item Data: ", result)
        
        if let itemImg = result.data?.item_img.nilIfEmpty {self.itemImg = itemImg}
        if let itemName = result.data?.item_name.nilIfEmpty {self.itemName = itemName}
        if let itemPrice = result.data?.item_price.nilIfEmpty {self.itemPrice = itemPrice}
        
        if self.itemImg == nil || self.itemName == nil && self.itemPrice == nil {
            SnackBar.shared.showSnackBar(self, message: .failShoppingLink)
            FolderDataManager().getFolderListDataManager(self)
            
            shareView.completeButton.inactivateButton()
            
        } else if self.itemPrice == nil {
            self.itemPrice = "0"
        }
        
        self.shareView.itemImage.kf.setImage(with: URL(string: itemImg ?? ""), placeholder: Image.blackLogo)
        self.shareView.itemNameTextField.text = self.itemName
        self.shareView.itemPriceTextField.text = FormatManager().strToPrice(numStr: itemPrice ?? "")
        
        // reload data with animation
        UIView.transition(with: shareView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { () -> Void in
                              self.shareView.reloadInputViews()},
                          completion: nil);
        
        shareView.completeButton.activateButton()
        FolderDataManager().getFolderListDataManager(self)
    }
    func getItemDataAPIFail() {
        SnackBar.shared.showSnackBar(self, message: .failShoppingLink)
        
        shareView.completeButton.inactivateButton()
        
        // 아이템 파싱에 실패해도 폴더리스트 조회
        FolderDataManager().getFolderListDataManager(self)
    }
    // MARK: 아이템 간편 등록
    func uploadItemAPISuccess(_ result: APIModel<ResultModel>) {
        if result.success {
            uploadItemAPIFunc()
        } else {
            // 500일때 뿐만 아니라 다른 이슈일 때도 에러바 출력
            // 401 일때도
            uploadItem500Error()
        }
        print("아이템 등록 🔥", result.message)
    }
    func uploadItemAPIFunc() {
        shareView.completeButton.activateButton()
        
        WishItemObserver.shared.notify(.upload)
        SnackBar.shared.showSnackBar(self, message: .addItem)
    }
    func uploadItem500Error() {
        shareView.completeButton.inactivateButton()
        
        ErrorBar(self)
    }
    func reloadDataAnimation() {
        // reload data with animation
        UIView.transition(with: shareView.folderCollectionView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { () -> Void in
                              self.shareView.folderCollectionView.reloadData()},
                          completion: nil);
    }
}
// MARK: - TextField & Keyboard Methods
extension ShareViewController: UITextFieldDelegate {
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
                self.view.frame.origin.y -= dif
                preKeyboardHeight = keyboardHeight
            } else if preKeyboardHeight > keyboardHeight {
                let dif = preKeyboardHeight - keyboardHeight
                self.view.frame.origin.y += dif
                preKeyboardHeight = keyboardHeight
            } else if preKeyboardHeight == keyboardHeight {
                self.view.endEditing(true)
                self.preKeyboardHeight = 0.0
            }
        }
        print("keyboard Will appear Execute")
    }
    
    @objc func keyboardWillDisappear(noti: NSNotification) {
        if self.view.frame.origin.y != restoreFrameValue {
            if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                self.view.frame.origin.y += keyboardHeight
            }
            print("keyboard Will Disappear Execute")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.frame.origin.y = restoreFrameValue
        print("touches Began Execute")
        self.view.endEditing(true)
        self.preKeyboardHeight = 0.0
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn Execute")
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing Execute")
        self.preKeyboardHeight = 0.0
        self.view.frame.origin.y = self.restoreFrameValue
        return true
    }
    
}
