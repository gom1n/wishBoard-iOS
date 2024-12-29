//
//  SplashViewController.swift
//  Wishboard
//
//  Created by gomin on 2023/12/24.
//

import Foundation
import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        setupUI()
        
        // get version data
        VersionDataManager().getVersionDataManager(self)
    }

    private func setupUI() {
        let logo = UIImageView().then {
            $0.image = Image.wishboardLogo
        }
        
        self.view.addSubview(logo)
        
        logo.snp.makeConstraints { make in
            make.width.equalTo(263)
            make.height.equalTo(32)
            make.center.equalToSuperview()
        }
        
        #if DEBUG
        self.setUpVersionLabel("dev")
        
//        #elseif REL
//        self.setUpVersionLabel("rel")

        #endif
        
    }
    
    private func setUpVersionLabel(_ version: String) {
        let debugVersion = UILabel().then {
            $0.text = "Version: \(Bundle.appVersion)(\(version))\nBuildVersion: \(Bundle.appBuildVersion)\nServer: \(Storage().BaseURL)"
            $0.numberOfLines = 0
            $0.font = UIFont.systemFont(ofSize: 10)
            $0.textColor = .gray_700
        }
        
        self.view.addSubview(debugVersion)
        
        debugVersion.snp.makeConstraints { make in
            make.bottom.leading.equalToSuperview().inset(50)
        }
    }

    func checkAppVersion(_ response: VersionModel) {
        
        // 1. 서버로부터 받은 데이터 (API 응답)
        guard let minVersion = response.minVersion,
              let recommendedVersion = response.recommendedVersion,
              let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        
        // 2. 버전 비교
        if isVersion(currentVersion, lessThan: minVersion) {
            // 강제 업데이트 알럿
            self.showForceUpdateAlert()
        } else if isVersion(currentVersion, lessThan: recommendedVersion) {
            // 권장 업데이트 알럿
            self.showRecommendUpdateAlert()
        } else {
            // 최신 버전, 다음 화면으로 이동
            moveToNextScreen()
        }
    }

    // 3. 버전 비교 헬퍼 함수
    private func isVersion(_ currentVersion: String, lessThan targetVersion: String) -> Bool {
        return currentVersion.compare(targetVersion, options: .numeric) == .orderedAscending
    }

    // 4. 알럿창 표시 함수
    /// 권장 업데이트 알럿
    private func showRecommendUpdateAlert() {
        let model = PopUpModel(title: "업데이트 안내",
                               message: "위시보드가 유저분들에게 더 나은 경험을\n제공하기 위해 사용성을 개선했어요!\n더 새로워진 위시보드를 만나보세요 😆",
                               greenBtnText: "업데이트",
                               blackBtnText: "나중에")
        let dialog = PopUpViewController(model)
        self.present(dialog, animated: false, completion: nil)
        
        dialog.cancelBtn.addTarget(self, action: #selector(quitButtonDidTap), for: .touchUpInside)
        dialog.okBtn.addTarget(self, action: #selector(appUpdateButtonDidTap), for: .touchUpInside)
    }
    /// 강제 업데이트 알럿
    private func showForceUpdateAlert() {
        let model = PopUpModel(title: "업데이트 안내",
                               message: "위시보드가 유저분들에게 더 나은 경험을\n제공하기 위해 사용성을 개선했어요!\n더 새로워진 위시보드를 만나보세요 😆",
                               btnText: "업데이트")
        let dialog = OneButtonPopUpViewController(model)
        self.present(dialog, animated: false, completion: nil)
        dialog.okBtn.addTarget(self, action: #selector(appUpdateButtonDidTap), for: .touchUpInside)
    }

    // 5. 화면 이동 함수 (알럿창 이벤트 완료 후)
    private func moveToNextScreen() {
        // 2초 후에 메인 화면으로 이동
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let navigationController = UINavigationController(rootViewController: OnBoardingViewController())
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(navigationController, animated: true)
        }
    }
    
    @objc private func appUpdateButtonDidTap() {
        // 앱 업데이트를 위해 앱스토어로 이동
        if let appStoreURL = URL(string: "https://itunes.apple.com/app/6443808936") {
            if UIApplication.shared.canOpenURL(appStoreURL) {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc private func quitButtonDidTap() {
        self.dismiss(animated: false)
        moveToNextScreen()
    }
}
