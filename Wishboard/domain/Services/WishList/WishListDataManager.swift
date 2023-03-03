//
//  WishListDataManager.swift
//  Wishboard
//
//  Created by gomin on 2022/09/27.
//

import Foundation
import Alamofire

class WishListDataManager {
    let header = APIManager().getHeader()
    
    // MARK: - 홈화면 위시리스트 조회 + 상세 조회
    func wishListDataManager(_ homeView: HomeView, _ viewcontroller: HomeViewController) {
        AF.request(Storage().BaseURL + "/item",
                           method: .get,
                           parameters: nil,
                           headers: header)
            .validate()
            .responseDecodable(of: [WishListModel].self) { response in
            switch response.result {
            case .success(let result):
                homeView.wishListAPISuccess(result)
            case .failure(let error):
                let statusCode = error.responseCode
                switch statusCode {
                case 429:
                    viewcontroller.wishListAPIFail()
                case 500:
                    DispatchQueue.main.async {
                        ErrorBar(viewcontroller)
                    }
                case 401:
                    RefreshDataManager().refreshDataManager(RefreshInput(accessToken: UserDefaults.standard.string(forKey: "accessToken") ?? "", refreshToken: UserDefaults.standard.string(forKey: "refreshToken") ?? ""))
                default:
                    print(error.responseCode)
                }
            }
        }
    }
}
