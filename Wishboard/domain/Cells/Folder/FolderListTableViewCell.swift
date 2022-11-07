//
//  FolderListTableViewCell.swift
//  Wishboard
//
//  Created by gomin on 2022/09/14.
//

import UIKit
import Kingfisher

class FolderListTableViewCell: UITableViewCell {
    let image = UIImageView().then{
        $0.backgroundColor = .systemGray6
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.contentMode = .scaleAspectFill
    }
    let folderName = UILabel().then{
        $0.text = "folderName"
        $0.font = UIFont.Suit(size: 14, family: .Regular)
        $0.numberOfLines = 1
    }
    let checkIcon = UIImageView().then{
        $0.image = UIImage(named: "check")
        $0.isHidden = true
    }

    //MARK: - Life Cycles
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpView()
        setUpConstraint()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: 테이블뷰의 셀이 재사용되기 전 호출되는 함수
    override func prepareForReuse() {
        super.prepareForReuse()

        image.image = nil
        folderName.text = nil
    }
    // MARK: - Functions
    func setUpView() {
        contentView.addSubview(image)
        contentView.addSubview(folderName)
        contentView.addSubview(checkIcon)
    }
    func setUpConstraint() {
        image.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        folderName.snp.makeConstraints { make in
            make.leading.equalTo(image.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(checkIcon.snp.leading).offset(-10)
        }
        checkIcon.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    func setUpData(_ data: FolderListModel) {
        if let image = data.folder_thumbnail {
            self.image.kf.setImage(with: URL(string: image), placeholder: UIImage())
        }
        if let foldername = data.folder_name {self.folderName.text = foldername}
    }
}
