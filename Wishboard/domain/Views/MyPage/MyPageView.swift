//
//  MyPageView.swift
//  Wishboard
//
//  Created by gomin on 2022/09/09.
//

import Foundation
import UIKit

class MyPageView: UIView {
    // MARK: - Life Cycles
    var mypageTableView: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Functions
    func setTableView(dataSourceDelegate: UITableViewDelegate & UITableViewDataSource) {
        mypageTableView = UITableView()
        mypageTableView.then{
            $0.delegate = dataSourceDelegate
            $0.dataSource = dataSourceDelegate
            $0.register(MypageProfileTableViewCell.self, forCellReuseIdentifier: "MypageProfileTableViewCell")
            
            // autoHeight
            $0.rowHeight = UITableView.automaticDimension
            $0.estimatedRowHeight = UITableView.automaticDimension
            $0.showsVerticalScrollIndicator = false
            $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
    }
    func setUpView() {
        addSubview(mypageTableView)
    }
    func setUpConstraint() {
        mypageTableView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
}
