//
//  ItemDetailTableViewCell.swift
//  Wishboard
//
//  Created by gomin on 2022/09/08.
//

import UIKit
import Kingfisher
import SnapKit

class ItemDetailTableViewCell: UITableViewCell {
    // MARK: - Properties
    let itemImage = UIImageView().then{
        $0.backgroundColor = .black_5
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 32
        $0.contentMode = .scaleAspectFill
    }
    var setFolderButton = UIButton().then{
        let title = "폴더를 지정해 보세요! > "
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font, value: TypoStyle.SuitD3.font, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: title.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    let dateLabel = UILabel().then{
        $0.setTypoStyleWithSingleLine(typoStyle: .SuitD3)
        $0.textColor = .gray_300
    }
    let itemNameLabel = DefaultLabel().then{
        $0.setTypoStyleWithMultiLine(typoStyle: .SuitB1)
        $0.numberOfLines = 0
    }
    let priceLabel = DefaultLabel().then{
        $0.text = Item.zero
        $0.setTypoStyleWithSingleLine(typoStyle: .MontserratH2)
    }
    let won = DefaultLabel().then{
        $0.text = Item.won
        $0.setTypoStyleWithSingleLine(typoStyle: .SuitD2)
    }
    let stack = UIStackView().then{
        $0.axis = .vertical
        $0.spacing = 0
    }
    
    private let linkView = UIView()
    private let memoView = UIView()
    
    // LinkView subViews
    let seperatorLine1 = UIView().then{
        $0.backgroundColor = .gray_100
    }
    let linkLabel = PaddingLabel(padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)).then{
        $0.textColor = .gray_200
        $0.setTypoStyleWithSingleLine(typoStyle: .SuitD3)
    }
    // MemoView subViews
    let seperatorLine2 = UIView().then{
        $0.backgroundColor = .gray_100
    }
    let memoTitlelabel = PaddingLabel(padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)).then{
        $0.text = Title.memo
        $0.setTypoStyleWithSingleLine(typoStyle: .SuitB2)
        $0.textColor = .gray_700
    }
    let memoContentLabel = PaddingLabel(padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)).then{
        $0.setTypoStyleWithMultiLine(typoStyle: .SuitD2)
        $0.numberOfLines = 0
        $0.textColor = .gray_700
    }
    // 재입고 초록색
    let restockLabel = PaddingLabel(padding: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)).then{
        $0.textColor = .gray_700
        $0.setTypoStyleWithSingleLine(typoStyle: .SuitB5)
        $0.backgroundColor = .green_500
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        
        $0.isHidden = true
    }
    let restockDateLabel = PaddingLabel(padding: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)).then{
        $0.textColor = .gray_700
        $0.setTypoStyleWithSingleLine(typoStyle: .SuitB5)
        $0.backgroundColor = .green_500
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        
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
    // MARK: - Functions
    func setUpView() {
        contentView.addSubview(itemImage)
        itemImage.addSubview(restockLabel)
        itemImage.addSubview(restockDateLabel)
        contentView.addSubview(setFolderButton)
        contentView.addSubview(dateLabel)
        contentView.addSubview(itemNameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(won)
        contentView.addSubview(stack)
        
        stack.addArrangedSubview(linkView)
        stack.addArrangedSubview(memoView)
        
        linkView.addSubview(seperatorLine1)
        linkView.addSubview(linkLabel)
        
        memoView.addSubview(seperatorLine2)
        memoView.addSubview(memoTitlelabel)
        memoView.addSubview(memoContentLabel)
    }
    func setUpConstraint() {
        itemImage.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(itemImage.snp.width).multipliedBy(1.154)
            make.top.equalToSuperview()
        }

        restockLabel.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(16)
        }
        restockDateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(restockLabel)
            make.leading.equalTo(restockLabel.snp.trailing).offset(9)
        }
        setFolderButton.snp.makeConstraints { make in
            make.leading.equalTo(itemImage)
            make.top.equalTo(itemImage.snp.bottom).offset(20)
        }
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalTo(itemImage.snp.trailing)
            make.centerY.equalTo(setFolderButton)
        }
        itemNameLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(itemImage)
            make.top.equalTo(setFolderButton.snp.bottom).offset(10)
        }
        priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(itemImage.snp.leading)
            make.top.equalTo(itemNameLabel.snp.bottom).offset(24)
        }
        won.snp.makeConstraints { make in
            make.leading.equalTo(priceLabel.snp.trailing)
            make.centerY.equalTo(priceLabel)
        }
        
        stack.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(priceLabel.snp.bottom).offset(16)
        }
        
        // LinkView
        seperatorLine1.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.top.leading.trailing.equalToSuperview()
        }
        linkLabel.snp.makeConstraints { make in
            make.top.equalTo(seperatorLine1.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.trailing.equalToSuperview().offset(-16)
        }
        // MemoView
        seperatorLine2.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.top.leading.trailing.equalToSuperview()
        }
        memoTitlelabel.snp.makeConstraints { make in
            make.top.equalTo(seperatorLine2.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
        memoContentLabel.snp.makeConstraints { make in
            make.top.equalTo(memoTitlelabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    // After API success
    func setUpData(_ data: WishListModel) {
        itemImage.layer.cornerRadius = itemImage.bounds.width / 10.7
        
        // Image
        let processor = TintImageProcessor(tint: .black_5)
        self.itemImage.kf.setImage(with: URL(string: data.item_img_url ?? ""), placeholder: Image.appLogo, options: [.processor(processor), .transition(.fade(0.5))])
        
        if let notificationType = data.item_notification_type {
            if let notificationDate = data.item_notification_date {
                self.restockLabel.isHidden = false
                self.restockDateLabel.isHidden = false
                let notiDateStr = FormatManager().showNotificationDateInItemDetail(notificationDate)
                self.restockLabel.text = notificationType
                self.restockDateLabel.text = notiDateStr
            }
        } else {
            self.restockLabel.isHidden = true
            self.restockDateLabel.isHidden = true
        }
        if let folderName = data.folder_name.nilIfEmpty {
            self.setFolderButton.setFolderButton(folderName)
        }
        
        if let createdDate = data.create_at {
            if let dateStr = FormatManager().createdDateToKoreanStr(createdDate) {
                self.dateLabel.text = dateStr
            }
        }
        if let itemName = data.item_name {self.itemNameLabel.text = itemName}
        if let itemPrice = data.item_price {self.priceLabel.text = FormatManager().strToPrice(numStr: itemPrice)}
        if let link = data.item_url.nilIfEmpty {
            // link 도메인만 보이게
            var url = URL(string: link)
            var domain = url?.host
            
            self.linkView.isHidden = false
            self.linkLabel.text = domain
        } else {
            self.linkView.isHidden = true
        }
        if let memo = data.item_memo.nilIfEmpty {
            self.memoView.isHidden = false
            self.memoContentLabel.text = memo
        } else {
            self.memoView.isHidden = true
        }
    }
}
