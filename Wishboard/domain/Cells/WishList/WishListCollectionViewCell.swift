//
//  WishListCollectionViewCell.swift
//  Wishboard
//
//  Created by gomin on 2022/09/08.
//

import UIKit
import Kingfisher

class WishListCollectionViewCell: UICollectionViewCell {
    static let identifier = "WishListCollectionViewCell"
    
    let itemImage = UIImageView().then{
        $0.backgroundColor = .black_5
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    let itemName = UILabel().then{
        $0.text = "itemName"
        $0.font = UIFont.Suit(size: 12.5, family: .Regular)
        $0.numberOfLines = 1
    }
    let itemPrice = UILabel().then{
        $0.text = "000,000"
        $0.font = UIFont.monteserrat(size: 14.58, family: .Bold)
    }
    let won = UILabel().then{
        $0.text = "원"
        $0.font = UIFont.Suit(size: 11.46, family: .Regular)
    }
    let cartButton = UIButton().then{
        $0.cartButton(.white)
    }
    
    // MARK: - Life Cycles
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setUpView()
        setUpConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: 테이블뷰의 셀이 재사용되기 전 호출되는 함수
    // 여기서 property들을 초기화해준다.
    override func prepareForReuse() {
        super.prepareForReuse()

        itemImage.image = UIImage()
    }
    // MARK: - Functions
    func setUpView() {
        contentView.addSubview(itemImage)
        contentView.addSubview(itemName)
        contentView.addSubview(itemPrice)
        contentView.addSubview(won)
        contentView.addSubview(cartButton)
    }
    func setUpConstraint() {
        itemImage.snp.makeConstraints { make in
            make.height.equalTo(itemImage.snp.width)
            make.leading.top.trailing.equalToSuperview()
        }
        itemName.snp.makeConstraints { make in
            make.top.equalTo(itemImage.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        itemPrice.snp.makeConstraints { make in
            make.top.equalTo(itemName.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(20)
        }
        won.snp.makeConstraints { make in
            make.centerY.equalTo(itemPrice)
            make.leading.equalTo(itemPrice.snp.trailing).offset(2)
        }
        cartButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.bottom.trailing.equalTo(itemImage).inset(10)
        }
    }
    
    func setUpData(_ data: WishListModel) {
        if let image = data.item_img_url {
            let processor = TintImageProcessor(tint: .black_5)
            self.itemImage.kf.setImage(with: URL(string: image), placeholder: UIImage(), options: [.processor(processor), .transition(.fade(0.5))])
        }
        if let name = data.item_name {self.itemName.text = name}
        if let price = data.item_price {self.itemPrice.text = FormatManager().strToPrice(numStr: price)}
        if let isCart = data.cart_state {
            if isCart == 1 {self.cartButton.cartButton(.wishboardGreen)}
            else {self.cartButton.cartButton(.white)}
        }
    }
}
