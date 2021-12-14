//
//  LoginController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 2/10/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import SnapKit

class LoginController: PageBaseController {
    
    private lazy var swipingView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isPagingEnabled = true
        view.backgroundColor = .white
        view.bounces = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private lazy var welcomeLabel : UILabel = {
        let view = Label()
        view.font =  Font.regular.uiFont(ofSize: 22)
        view.textColor = .white
        view.text = "Welcome"
        return view
    }()
    
    
    private lazy var pageControll : UIPageControl = {
        let view = UIPageControl()
        view.numberOfPages = OnboardingPageDataSource.items.count
        view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        view.pageIndicatorTintColor = Color.gray.uiColor
        view.currentPageIndicatorTintColor = .white
        return view
    }()
    
    /*
    private lazy var facebookButton : ArrowButton = {
        let view = ArrowButton(image: Image.facebook.uiImage, labelText: "Facebook login")
        view.borderWidth = 0
        view.addTarget(self, action: #selector(loginFacebookAction), for: .touchUpInside)
        view.setTitleColor(.white)
        view.backgroundColor = Color.buttonColor.uiColor
        view.setFont(Font.regular.uiFont(ofSize: 14))
        return view
    }()
    
    private var googleButton : ArrowButton = {
        let view = ArrowButton(image: Image.google.uiImage, labelText: "Google login")
        view.addTarget(self, action: #selector(loginGoogleAction), for: .touchUpInside)
        view.setImageCornerRadius(0)
        view.setTitleColor(.white)
        
        
        view.borderWidth = 0
        view.backgroundColor = Color.buttonColor.uiColor
        view.setFont(Font.regular.uiFont(ofSize: 14))
        
        return view
    }()
    */
    
    private lazy var loginButton: PrimaryButton = {
        let view = PrimaryButton()
        view.setTitle("Get started", for: .normal)
        view.addTarget(self, action: #selector(loginSmsAction), for: .touchUpInside)
        return view
    }()
    
    private var termsLabel: FlexibleTextView = {
        let label = FlexibleTextView()
        label.texts = [
            ("By joining you accept our ", nil),
            ("Terms and Conditions", URL(string: "https://Sparks.ge")),
            (" and ", nil),
            ("Privacy Policy", URL(string: "https://Sparks.ge"))
        ]
        label.maxFontSize = 15
        label.textPartColor = Color.lightPurple.uiColor
        label.urlPartColor = Color.fadedPurple.uiColor
        label.backgroundColor = .clear
        label.alignment = .center
        return label
    }()
    
    override func configure() {
        super.configure()
        swipingView.delegate = self
        swipingView.dataSource = self
        swipingView.register(PageCell.self, forCellWithReuseIdentifier: "cellId")
        layout()
    }
    
    override func didAppear() {
        super.didAppear()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func layout(){
        view.addSubview(welcomeLabel)
        welcomeLabel.snp.makeConstraints {
            $0.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
        }
        
        view.addSubview(pageControll)
        pageControll.snp.makeConstraints {
            $0.right.equalToSuperview().offset(16)
            $0.centerY.equalTo(welcomeLabel.snp.centerY)
        }
        
        
        view.addSubview(termsLabel)
        termsLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.height.equalTo(64)
        }
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints {
            $0.bottom.equalTo(termsLabel.snp.top).offset(-16)
            $0.left.equalToSuperview().inset(45)
            $0.right.equalToSuperview().inset(45)
            $0.height.equalTo(64)
        }
        
        view.addSubview(swipingView)
        swipingView.snp.makeConstraints {
            $0.top.equalTo(welcomeLabel.snp.bottom).offset(30)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(loginButton.snp.top)
        }
    }
    
    @objc private func loginFacebookAction(sender: AnyObject) {
        
        Service.auth.fbAuth(controller: self) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(error)
                break
            case .success(_):
                AppDelegate.updateRootViewController()
                break
            }
        }
    }
    
    @objc private func loginGoogleAction(sender: AnyObject) {
        
        Service.auth.googleAuth(controller: self) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(error)
                break
            case .success(_):
                AppDelegate.updateRootViewController()
                break
            }
        }
    }
    
    @objc private func loginSmsAction(sender: AnyObject) {
        self.pageViewController?.switchTabToNext(parameters: nil)
    }
}

extension LoginController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollViewOffset = scrollView.contentOffset.x
        let scrollViewWidth = scrollView.bounds.size.width
        let currentPage = Int(ceil(scrollViewOffset/scrollViewWidth))
        pageControll.currentPage = currentPage
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return OnboardingPageDataSource.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath as IndexPath) as! PageCell
        cell.setupWith(index: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: swipingView.frame.width, height: swipingView.frame.height )
    }
}
