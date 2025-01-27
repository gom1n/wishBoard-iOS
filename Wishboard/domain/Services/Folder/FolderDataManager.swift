//
//  FolderDataManager.swift
//  Wishboard
//
//  Created by gomin on 2022/09/28.
//

import Foundation
import Alamofire

class FolderDataManager {
    
    // MARK: - 폴더 조회
    func getFolderDataManager(_ viewcontroller: FolderViewController) {
        let url = Storage().BaseURL + "/folder"
        let request = AlamofireBaseService.shared.requestWithParameter(url, .get, viewcontroller)
        
        AlamofireBaseService.shared.responseWithErrorException(request, [FolderModel].self) { result in
            if let response = result as? [FolderModel] {
                viewcontroller.getFolderAPISuccess(response)
            } else if let errorCode = result as? Int, errorCode == 404 {
                viewcontroller.noFolder()
            }
        }
               
    }
    // MARK: - 폴더 추가
    func addFolderDataManager(_ parameter: AddFolderInput, _ viewcontroller: NewFolderBottomSheetViewController, _ preVC: FolderViewController) {
        
        let url = Storage().BaseURL + "/folder"
        let request = AlamofireBaseService.shared.requestWithBody(url, .post, parameter, preVC)
        
        AlamofireBaseService.shared.responseWithErrorException(request, APIModel<ResultModel>.self) { result in
            if let response = result as? APIModel<ResultModel> {
                preVC.addFolderAPISuccess(response)
            } else if let errorCode = result as? Int, errorCode == 409 {
                viewcontroller.sameFolderNameFail()
            }
        }
        
    }
    // MARK: - 폴더명 수정
    func modifyFolderDataManager(_ folderId: Int, _ parameter: AddFolderInput, _ viewcontroller: ModifyFolderBottomSheetViewController, _ preVC: FolderViewController) {
        
        let url = Storage().BaseURL + "/folder/\(folderId)"
        let request = AlamofireBaseService.shared.requestWithBody(url, .put, parameter, preVC)
        
        AlamofireBaseService.shared.responseWithErrorException(request, APIModel<ResultModel>.self) { result in
            if let response = result as? APIModel<ResultModel> {
                preVC.modifyFolderAPISuccess(response)
            } else if let errorCode = result as? Int, errorCode == 409 || errorCode == 400 || errorCode == 404 {
                viewcontroller.sameFolderNameFail()
            }
        }
    }
    // MARK: - 폴더 삭제
    func deleteFolderDataManager(_ folderId: Int, _ viewcontroller: FolderViewController) {
        
        let url = Storage().BaseURL + "/folder/\(folderId)"
        let request = AlamofireBaseService.shared.requestWithParameter(url, .delete, viewcontroller)
        
        AlamofireBaseService.shared.responseDecoded(request, APIModel<ResultModel>.self) { result in
            viewcontroller.deleteFolderAPISuccess(result)
        }
        
    }
    // MARK: - 폴더 리스트 조회
    func getFolderListDataManager(_ viewcontroller: SetFolderBottomSheetViewController) {
        
        let url = Storage().BaseURL + "/folder/list"
        let request = AlamofireBaseService.shared.requestWithParameter(url, .get, viewcontroller)
        
        AlamofireBaseService.shared.responseDecoded(request, [FolderListModel].self) { result in
            viewcontroller.getFolderListAPISuccess(result)
        }
        
    }
    // MARK: - 폴더 내 아이템 조회
    func getFolderDetailDataManager(_ folderId: Int, _ viewcontroller: FolderDetailViewController) {
        
        let url = Storage().BaseURL + "/folder/item/\(folderId)"
        let request = AlamofireBaseService.shared.requestWithParameter(url, .get, viewcontroller)
        
        AlamofireBaseService.shared.responseWithErrorException(request, [WishListModel].self) { result in
            if let response = result as? [WishListModel] {
                viewcontroller.getFolderDetailAPISuccess(response)
            } else if let errorCode = result as? Int, errorCode == 404 {
                viewcontroller.noWishList()
            }
        }
    
    }
    // MARK: - 아이템의 폴더 수정
    func modifyItemFolderDataManager(_ itemId: Int, _ folderId: Int, _ viewcontroller: SetFolderBottomSheetViewController) {
        
        let url = Storage().BaseURL + "/item/\(itemId)/folder/\(folderId)"
        let request = AlamofireBaseService.shared.requestWithParameter(url, .put, viewcontroller)
        
        AlamofireBaseService.shared.responseDecoded(request,  APIModel<ResultModel>.self) { result in
            viewcontroller.modifyItemFolderAPISuccess(result)
        }
        
    }
}
