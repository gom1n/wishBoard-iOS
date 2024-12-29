//
//  CartView.swift
//  Wishboard
//
//  Created by gomin on 2022/09/08.
//

import Foundation
import UIKit

class CartView: UIView {
    // MARK: - Properties
    // lower View
    let lowerView = UIView().then{
        $0.backgroundColor = .green_500
    }
    let total = DefaultLabel().then{
        $0.text = Item.total
        $0.setTypoStyleWithSingleLine(typoStyle: .SuitD2)
    }
    let countLabel = DefaultLabel().then{
        $0.text = Item.zero
        $0.setTypoStyleWithSingleLine(typoStyle: .MontserratH2)
    }
    let label = DefaultLabel().then{
        $0.text = Item.count
        $0.setTypoStyleWithSingleLine(typoStyle: .SuitD2)
    }
    let price = DefaultLabel().then{
        $0.text = Item.zero
        $0.setTypoStyleWithSingleLine(typoStyle: .MontserratH2)
    }
    let won = DefaultLabel().then{
        $0.text = Item.won
        $0.setTypoStyleWithSingleLine(typoStyle: .SuitD2)
    }
    // MARK: - Life Cycles
    var preVC: CartViewController!
    var cartTableView: UITableView!
    var cartData: [CartListModel] = []
    var itemPrice = 0
    let emptyMessage = EmptyMessage.cart
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTableView()
        setUpView()
        setUpConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setTableView() {
        cartTableView = UITableView()
        cartTableView.delegate = self
        cartTableView.dataSource = self
        cartTableView.register(CartTableViewCell.self, forCellReuseIdentifier: "CartTableViewCell")
        
        // autoHeight
        cartTableView.rowHeight = UITableView.automaticDimension
        cartTableView.estimatedRowHeight = UITableView.automaticDimension
        cartTableView.showsVerticalScrollIndicator = false
        cartTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func setUpView() {
        addSubview(lowerView)
        lowerView.addSubview(total)
        lowerView.addSubview(countLabel)
        lowerView.addSubview(label)
        lowerView.addSubview(price)
        lowerView.addSubview(won)
        
        addSubview(cartTableView)
    }
    func setUpConstraint() {
        setUpLowerConstraint()
        
        cartTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(lowerView.snp.top)
        }
    }
    func setUpLowerConstraint() {
        lowerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            if UIDevice.current.hasNotch {make.height.equalTo(78)}
            else {make.height.equalTo(50)}
        }
        total.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(17)
            make.top.equalToSuperview().offset(16)
        }
        countLabel.snp.makeConstraints { make in
            make.centerY.equalTo(total)
            make.leading.equalTo(total.snp.trailing).offset(4)
        }
        label.snp.makeConstraints { make in
            make.centerY.equalTo(total)
            make.leading.equalTo(countLabel.snp.trailing)
        }
        won.snp.makeConstraints { make in
            make.centerY.equalTo(total)
            make.trailing.equalToSuperview().offset(-18)
        }
        price.snp.makeConstraints { make in
            make.centerY.equalTo(total)
            make.trailing.equalTo(won.snp.leading)
        }
    }
}
// MARK: - Main TableView delegate
extension CartView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = cartData.count ?? 0
        EmptyView().setEmptyView(self.emptyMessage, self.cartTableView, count)
        return count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as? CartTableViewCell else { return UITableViewCell() }
        
        let itemIdx = indexPath.item
        cell.setUpData(self.cartData[itemIdx])
        
        // 수량 변경 버튼 이벤트
        let plusGesture = CartGesture(target: self, action: #selector(plusButtonDidTap(_:)))
        let minusGesture = CartGesture(target: self, action: #selector(minusButtonDidTap(_:)))
        let deleteGesture = CartGesture(target: self, action: #selector(deleteButtonDidTap(_:)))
        
        plusGesture.cartItem = self.cartData[itemIdx]
        minusGesture.cartItem = self.cartData[itemIdx]
        deleteGesture.cartItem = self.cartData[itemIdx]
        
        cell.plusButton.addGestureRecognizer(plusGesture)
        cell.minusButton.addGestureRecognizer(minusGesture)
        cell.deleteButton.addGestureRecognizer(deleteGesture)
        
        // 장바구니 아이템 클릭 이벤트 (이미지, 상품명만)
        let cartItemImageGesture = CartGesture(target: self, action: #selector(cartItemDidTap(_:)))
        cartItemImageGesture.cartItem = self.cartData[itemIdx]
        cell.itemImage.addGestureRecognizer(cartItemImageGesture)
        
        let cartItemNameGesture = CartGesture(target: self, action: #selector(cartItemDidTap(_:)))
        cartItemNameGesture.cartItem = self.cartData[itemIdx]
        cell.itemName.addGestureRecognizer(cartItemNameGesture)
        
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension CartView {
    // (+) 버튼 클릭
    @objc func plusButtonDidTap(_ sender: CartGesture) {
        UIDevice.vibrate()
        guard let itemId = sender.cartItem?.wishItem?.item_id else {return}
        guard var itemCount = sender.cartItem?.cartItemInfo?.item_count else {return}
        itemCount = itemCount + 1
        
        let modifyCountInput = CartModifyCountInput(item_count: itemCount)
        CartDataManager().modifyCountDataManager(itemId, modifyCountInput, self)
    }
    // (-) 버튼 클릭
    @objc func minusButtonDidTap(_ sender: CartGesture) {
        UIDevice.vibrate()
        guard let itemId = sender.cartItem?.wishItem?.item_id else {return}
        guard var itemCount = sender.cartItem?.cartItemInfo?.item_count else {return}
        if itemCount == 1 {return}
        else {itemCount = itemCount - 1}
        
        let modifyCountInput = CartModifyCountInput(item_count: itemCount)
        CartDataManager().modifyCountDataManager(itemId, modifyCountInput, self)
    }
    // (X) 버튼 클릭
    @objc func deleteButtonDidTap(_ sender: CartGesture) {
        UIDevice.vibrate()
        let model = PopUpModel(title: "장바구니에서 삭제",
                               message: "정말 장바구니에서 아이템을 삭제하시겠어요?",
                               greenBtnText: "삭제",
                               blackBtnText: "취소")
        let dialog = PopUpViewController(model, .delete)
        self.preVC.present(dialog, animated: false, completion: nil)
        
        let deleteGesture = CartGesture(target: self, action: #selector(deleteItem(_:)))
        deleteGesture.cartItem = sender.cartItem
        dialog.okBtn.addGestureRecognizer(deleteGesture)
    }
    @objc func deleteItem(_ sender: CartGesture) {
        UIDevice.vibrate()
        guard let itemId = sender.cartItem?.wishItem?.item_id else {return}
        CartDataManager().deleteCartDataManager(itemId, self)
        
    }
    // 상품 이미지, 상품명 클릭 (아이템 디테일 화면으로 이동)
    @objc func cartItemDidTap(_ sender: CartGesture) {
        UIDevice.vibrate()
        guard let itemId = sender.cartItem?.wishItem?.item_id else {return}
        let vc = ItemDetailViewController()
        vc.itemId = itemId
        self.preVC.navigationController?.pushViewController(vc, animated: true)
    }
    // MARK: 계산
    func calculate() {
        var totalPrice = 0
        var totalCount = 0
        for data in cartData {
            guard let initPrice = data.wishItem?.item_price else {return}
            guard let count = data.cartItemInfo?.item_count else {return}
            
            totalPrice = totalPrice + Int(initPrice)! * count
            totalCount = totalCount + count
        }
        /// 아이템 수: 고유한 아이템 자체의 개수
        /// 총 가격: 장바구니에 넣은 수량에 가격을 곱한 만큼의 총 가격
        self.price.text = FormatManager().strToPrice(numStr: String(totalPrice))
        self.countLabel.text = String(cartData.count)
    }
}
// MARK: - API Success
extension CartView {
    // MARK: Cart 조회 API
    func getCartListAPISuccess(_ result: [CartListModel]) {
        self.cartData = result
        if result.isEmpty {
            noCartItem()
            return
        }
        
        // reload data with animation
        UIView.transition(with: cartTableView,
                                  duration: 0.35,
                                  options: .transitionCrossDissolve,
                                  animations: { () -> Void in
                                    self.cartTableView.reloadData()},
                                completion: nil);
        calculate()
    }
    
    func noCartItem() {
        self.cartData = []
        cartTableView.reloadData()
        self.price.text = Item.zero
        self.countLabel.text = Item.zero
    }
    // MARK: 장바구니 수량 변경 API
    func modifyCountAPISuccess(_ result: APIModel<TokenResultModel>) {
        CartDataManager().getCartListDataManager(self)
        print(result.message)
    }
    // MARK: 장바구니 삭제 API
    func deleteCartAPISuccess(_ result: APIModel<TokenResultModel>) {
        self.preVC.dismiss(animated: false)
        CartDataManager().getCartListDataManager(self)
        SnackBar.shared.showSnackBar(preVC, message: .deleteCartItem)
        WishItemObserver.shared.notify(.cartItemDelete)
    }
}
// MARK: - CartGesture
class CartGesture: UITapGestureRecognizer {
    var cartItem: CartListModel?
}
