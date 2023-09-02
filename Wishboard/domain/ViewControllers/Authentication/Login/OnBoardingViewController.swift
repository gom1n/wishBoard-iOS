//
//  OnBoardingViewController.swift
//  Wishboard
//
//  Created by gomin on 2022/09/05.
//

import UIKit

/*
 Onboarding TODO
 서버 이전 알럿창 api 요청
 */

class OnBoardingViewController: UIViewController {
    
    convenience init(usecase: ObserverUseCase) {
        self.init()

        if usecase == .signOut {
            SnackBar(self, message: .deleteUser)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        // 자동 로그인
        checkRememberMe()
    }
    override func viewDidAppear(_ animated: Bool) {
        // 현재 앱 버전과 앱 스토어에 있는 앱버전을 비교 후 알럿창 띄우기
        compareAppVersionAndAlert(loadAppStoreVersion())
        
        self.tabBarController?.tabBar.isHidden = true
        // Network Check
        NetworkCheck.shared.startMonitoring(vc: self)
    }
    /// 자동로그인 로직 구현
    func checkRememberMe() {
        if let token = UserManager.accessToken {
            // go Main
            ScreenManager().goMain(self)
        }
    }
}
extension OnBoardingViewController {
    private func setLayout() {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.tabBarController?.tabBar.isHidden = true

        let view = OnBoardingView()
        view.setViewController(self)
        self.view.addSubview(view)

        view.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    /// 서버 이전 등의 이슈로 안내 알럿창을 띄워야할 때
    private func showServiceInspectionAlert() {
        let model = PopUpModel(title: "서비스 일시 중단 안내",
                               message: "서버 이전으로 서비스가\n일시 중단되오니 양해 부탁드립니다.\n보다 안정적인 위시보드로 곧 돌아올게요!\n자세한 사항은 공지사항을 확인해 주세요 😉",
                               greenBtnText: "공지사항 확인",
                               blackBtnText: "앱 종료")
        let dialog = PopUpViewController(model)
        self.present(dialog, animated: false, completion: nil)

        dialog.cancelBtn.addTarget(self, action: #selector(appNoticeButtonDidTap), for: .touchUpInside)
        dialog.okBtn.addTarget(self, action: #selector(exitButtonDidTap), for: .touchUpInside)
    }
    @objc func appNoticeButtonDidTap() {
        // 인스타그램 이동
        ScreenManager().linkTo(viewcontroller: self, "https://www.instagram.com/p/CtN6KfUPqbI/?igshid=NTc4MTIwNjQ2YQ==")
    }
    @objc func exitButtonDidTap() {
        // 애니메이션을 주어 앱 종료시키기
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exit(0)
        }
    }
    /// 앱스토어에 있는 버전 가져오기
    func loadAppStoreVersion() -> String {
        let bundleID = "gomin.Wishboard"
        let appStoreUrl = "http://itunes.apple.com/lookup?bundleId=\(bundleID)"
        guard let url = URL(string: appStoreUrl),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
              let results = json["results"] as? [[String: Any]] else {
            return ""
        }
                
        guard let appStoreVersion = results[0]["version"] as? String else {
            return ""
        }
        return appStoreVersion
    }
    /// 현재 앱 버전과 앱 스토어에 있는 앱버전을 비교 후 알럿창 띄우기
    func compareAppVersionAndAlert(_ appStoreVersion: String) {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let comparisonResult = appVersion.compare(appStoreVersion, options: .numeric)
           
            if comparisonResult == .orderedAscending {
                // 앱 스토어 버전이 더 높음, 업데이트 알림
                let model = PopUpModel(title: "업데이트 안내",
                                       message: "위시보드가 유저분들에게 더 나은 경험을\n제공하기 위해 사용성을 개선했어요!\n더 새로워진 위시보드를 만나보세요 😆",
                                       greenBtnText: "업데이트",
                                       blackBtnText: "나중에")
                let dialog = PopUpViewController(model)
                self.present(dialog, animated: false, completion: nil)
                
                dialog.cancelBtn.addTarget(self, action: #selector(appUpdateButtonDidTap), for: .touchUpInside)
                dialog.okBtn.addTarget(self, action: #selector(quitButtonDidTap), for: .touchUpInside)
            }
        }
    }
    @objc func appUpdateButtonDidTap() {
        // 앱 업데이트를 위해 앱스토어로 이동
        if let appStoreURL = URL(string: "https://itunes.apple.com/app/6443808936") {
            if UIApplication.shared.canOpenURL(appStoreURL) {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
            }
        }
    }
    @objc func quitButtonDidTap() {
        self.dismiss(animated: false)
    }

}
