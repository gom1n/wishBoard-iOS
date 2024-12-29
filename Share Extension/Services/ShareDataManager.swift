//
//  ShareDataManager.swift
//  Share Extension
//
//  Created by gomin on 2022/09/29.
//

import Foundation
import Alamofire

class ShareDataManager {
    let defaults = UserDefaults(suiteName: "group.gomin.Wishboard.Share")
    
    // MARK: - 아이템 정보 파싱
    func getItemDataDataManager(_ url: String, _ viewcontroller: ShareViewController) {
        let BaseURL = defaults?.string(forKey: "url") ?? ""
        let token = defaults?.string(forKey: "accessToken") ?? ""
        // 로그아웃 상태일 때
        if token == "" {
            viewcontroller.needLogin()
            return
        }
        
        let header: HTTPHeaders = [
            "Authorization": "Bearer " + token,
            "Content-type": "application/json",
            "User-Agent": Storage().AgentHeader
        ]
        AF.request(BaseURL + "/item/parse?site=\(url)",
                           method: .get,
                           parameters: nil,
                           headers: header,
                           interceptor: AuthInterceptor.shared)
            .validate()
            .responseDecodable(of: APIModel<ItemParsingModel>.self) { response in
                print(BaseURL + "/item/parse?site=\(url)")
            switch response.result {
            case .success(let result):
                viewcontroller.getItemDataAPISuccess(result)
            case .failure(let error):
                let statusCode = error.responseCode
                switch statusCode {
                case 404:
                    viewcontroller.getItemDataAPIFail()
                case 401:
                    RefreshDataManager().refreshDataManager {
                        $0 ? viewcontroller.getWebURL() : viewcontroller.getItemDataAPIFail()
                    }
                    viewcontroller.getFolderListAPIFail()
                default:
                    print(error.localizedDescription)
                    print(error.responseCode)
                    viewcontroller.getItemDataAPIFail()
                }
            }
        }
    }
    // MARK: - 아이템 간편 등록
    func uploadItemDataManager(_ folderId: Int?,
                               _ photo: UIImage?,
                               _ itemName: String,
                               _ itemPrice: String,
                               _ itemURL: String,
                               _ itemMemo: String,
                               _ itemNotificationType: String?,
                               _ itemNotificationDate: String?,
                               _ viewcontroller: ShareViewController) {
        
        let BaseURL = defaults?.string(forKey: "url") ?? ""
        let token = defaults?.string(forKey: "accessToken") ?? ""
        
        let multiHeader: HTTPHeaders = [
            "Content-type": "multipart/form-data",
            "Authorization": "Bearer " + token,
            "User-Agent": Storage().AgentHeader
        ]
        
        let uploadItemUrl = BaseURL + "/item"
        
        //PUT 함수로 전달할 String 데이터, 이미지 데이터는 제외하고 구성
        var body: Parameters = [
            "item_name" : itemName,
            "item_price" : itemPrice,
            "item_url" : itemURL,
            "item_memo" : itemMemo,
        ]
        if let folderId = folderId, folderId != -1 {
            body.updateValue(folderId, forKey: "folder_id")
        }
        if let itemNotificationType = itemNotificationType {
            body.updateValue(itemNotificationType, forKey: "item_notification_type")
        }
        if let itemNotificationDate = itemNotificationDate {
            /// 시간을 알맞은 형식으로 전환
            /// 23년 09월 16일 13:30 -> 2023-09-16 13:30:00
            let notificationDate = FormatManager().koreanStrToDate(itemNotificationDate)! + ":00"
            body.updateValue(notificationDate, forKey: "item_notification_date")
        }
        
        AF.upload(multipartFormData: { (multipart) in
            if let imageData = photo?.resizeImageIfNeeded().jpegData(compressionQuality: 1.0) {
                multipart.append(imageData, withName: "item_img", fileName: "photo.jpg", mimeType: "image/jpeg")
                //이미지 데이터를 POST할 데이터에 덧붙임
            }
            for (key, value) in body {
                multipart.append("\(value)".data(using: .utf8, allowLossyConversion: false)!, withName: key)
                //이미지 데이터 외에 같이 전달할 데이터 (여기서는 idx, name, introduction 등)
            }
        }
        ,to: URL(string: uploadItemUrl)!    //전달할 url
        ,method: .post        //전달 방식
        ,headers: multiHeader) //헤더
        .responseData { response in
            switch response.result {
                case let .success(data):
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(APIModel<ResultModel>.self, from: data)
                        viewcontroller.uploadItemAPISuccess(result)
                        print(result)
                    } catch {
                        print("error", data)
                    }
                case let .failure(error): // 요청 x
                print(error.responseCode)
            }
        }
    }
}
