//
//  UserService.swift
//  Wishboard
//
//  Created by gomin on 2023/03/20.
//

import Foundation
import Moya

final class UserService{
    static let shared = UserService()
    private init() { }
    let provider = MultiMoyaService(plugins: [MoyaLoggerPlugin()])
}

extension UserService{
    
    func signIn(model: LoginInput, completion: @escaping (Result<APIModel<TokenResultModel>, Error>) -> Void) {
        provider.requestDecoded(UserRouter.signIn(param: model)) { response in
            completion(response)
        }
    }
}
