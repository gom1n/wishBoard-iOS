//
//  VersionModel.swift
//  Wishboard
//
//  Created by gomin on 9/25/24.
//

import Foundation

struct VersionModel: Decodable {
    let platform: String?
    let minVersion: String?
    let recommendedVersion: String?
}
