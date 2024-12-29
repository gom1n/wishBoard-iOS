//
//  FolderViewController.swift
//  Wishboard
//
//  Created by gomin on 2022/09/08.
//

import UIKit
import Lottie
import MaterialComponents.MaterialBottomSheet

class FolderViewController: TitleLeftViewController {
    var folderView : FolderView!
    let emptyMessage = EmptyMessage.folder
    var folderData: [FolderModel] = []
    
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        super.navigationTitle.text = Title.folder

        setFolderView()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.isNavigationBarHidden = true
        // DATA
        FolderDataManager().getFolderDataManager(self)
    }
//    override func viewWillAppear(_ animated: Bool) {
//        FolderDataManager().getFolderDataManager(self)
//    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func rightPositionBtnDidClicked() {
        showAddNewFolderBottomSheet()
    }
}
// MARK: - CollectionView delegate
extension FolderViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = folderData.count ?? 0
        EmptyView().setEmptyView(self.emptyMessage, self.folderView.folderCollectionView, count)
        return count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCollectionViewCell.identifier,
                                                            for: indexPath)
                as? FolderCollectionViewCell else{ fatalError() }
        let itemIdx = indexPath.item
        cell.setUpData(self.folderData[itemIdx])
        
        let folderMenuGesture = CustomButton(target: self, action: #selector(alertFolderMenu(_:)))
        folderMenuGesture.folderData = self.folderData[itemIdx]
        cell.moreButton.addGestureRecognizer(folderMenuGesture)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIDevice.vibrate()
        
        let itemIdx = indexPath.item
        let folderName = self.folderData[itemIdx].folder_name
        let folderId = self.folderData[itemIdx].folder_id
        
        let vc = FolderDetailViewController()
        vc.folderName = folderName
        vc.folderId = folderId
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
// MARK: - Functions & Actions
extension FolderViewController {
    func setFolderView() {
        folderView = FolderView()
        self.view.addSubview(folderView)
        
        let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0
        folderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(super.navigationView.snp.bottom)
            make.bottom.equalToSuperview().offset(-tabBarHeight)
        }
        
        folderView.setCollectionView(self)
        folderView.setUpView()
        folderView.setUpConstraint()
        
        initRefresh()
    }
    // 폴더 메뉴 하단 팝업창
    @objc func alertFolderMenu(_ sender: CustomButton) {
        UIDevice.vibrate()
        
        guard let folderData = sender.folderData else {return}
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let modifyAction =  UIAlertAction(title: "폴더명 수정", style: UIAlertAction.Style.default){(_) in
            self.alertModifyDialog(folderData: folderData)
        }
        let deleteAction =  UIAlertAction(title: "폴더 삭제", style: UIAlertAction.Style.default){(_) in
            self.alertDeleteDialog(folderData: folderData)
        }
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.view.tintColor = .gray_700
        alert.addAction(modifyAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    // 새 폴더 추가 BottomSheet
    func showAddNewFolderBottomSheet() {
        UIDevice.vibrate()
        let vc = NewFolderBottomSheetViewController()
        vc.preVC = self
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: vc)
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 317
        bottomSheet.dismissOnDraggingDownSheet = false
        
        self.present(bottomSheet, animated: true, completion: nil)
    }
    
    // 폴더명 수정 팝업창
    func alertModifyDialog(folderData: FolderModel) {
        UIDevice.vibrate()
        
        let vc = ModifyFolderBottomSheetViewController()
        vc.preVC = self
        vc.folderData = folderData
        
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: vc)
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 317
        bottomSheet.dismissOnDraggingDownSheet = false
        
        self.present(bottomSheet, animated: true, completion: nil)
    }
    // 폴더 삭제 팝업창
    func alertDeleteDialog(folderData: FolderModel) {
        UIDevice.vibrate()
        let model = PopUpModel(title: "폴더 삭제",
                               message: "정말 폴더를 삭제하시겠어요?\n폴더가 삭제되어도 아이템은 사라지지 않아요.",
                               greenBtnText: "삭제",
                               blackBtnText: "취소")
        let dialog = PopUpViewController(model, .delete)
        self.present(dialog, animated: false, completion: nil)
        
        let folderMenuGesture = CustomButton(target: self, action: #selector(deleteFolderButtonDidTap(_:)))
        folderMenuGesture.folderData = folderData
        dialog.okBtn.addGestureRecognizer(folderMenuGesture)
    }
    // 폴더 삭제 버튼 클릭
    @objc func deleteFolderButtonDidTap(_ sender: CustomButton) {
        UIDevice.vibrate()
        guard let folderId = sender.folderData?.folder_id else {return}
        FolderDataManager().deleteFolderDataManager(folderId, self)
    }
}

// MARK: - API Success
extension FolderViewController {
    // MARK: 폴더 조회 API
    func getFolderAPISuccess(_ result: [FolderModel]) {
        self.folderData = result
        if result.isEmpty {
            noFolder()
            return
        }
        // reload data with animation
        UIView.transition(with: folderView.folderCollectionView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { () -> Void in
                              self.folderView.folderCollectionView.reloadData()},
                          completion: nil);
        refreshControl.endRefreshing()
    }
    func noFolder() {
        self.folderData = []
        // reload data with animation
        UIView.transition(with: folderView.folderCollectionView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { () -> Void in
                              self.folderView.folderCollectionView.reloadData()},
                          completion: nil);
    }
    // MARK: 폴더 추가 API
    func addFolderAPISuccess(_ result: APIModel<ResultModel>) {
        self.dismiss(animated: false)
        SnackBar.shared.showSnackBar(self, message: .addFolder)
        FolderDataManager().getFolderDataManager(self)
        print(result.message)
    }
    // MARK: 폴더명 수정 API
    func modifyFolderAPISuccess(_ result: APIModel<ResultModel>) {
        self.dismiss(animated: false)
        SnackBar.shared.showSnackBar(self, message: .modifyFolder)
        FolderDataManager().getFolderDataManager(self)
        print(result.message)
    }
    func sameFolderNameFail() {
        
    }
    // MARK: 폴더 삭제 API
    func deleteFolderAPISuccess(_ result: APIModel<ResultModel>) {
        self.dismiss(animated: false)
        SnackBar.shared.showSnackBar(self, message: .deleteFolder)
        FolderDataManager().getFolderDataManager(self)
        print(result.message)
    }
}
extension FolderViewController {
    func initRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        
        refreshControl.backgroundColor = .white
        refreshControl.tintColor = .gray_700
        
        folderView.folderCollectionView.refreshControl = refreshControl
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // DATA reload
            FolderDataManager().getFolderDataManager(self)
            self.folderView.folderCollectionView.reloadData()
            refresh.endRefreshing()
        }
    }
}
// MARK: - 버튼 클릭 Gesture Recognizer
class CustomButton: UITapGestureRecognizer {
    var folderData: FolderModel?
}
