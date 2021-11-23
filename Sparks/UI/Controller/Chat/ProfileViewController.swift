//
//  ProfileViewController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 8/26/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import UIKit
import SnapKit

protocol ProfileViewDelegate: AnyObject {
    func didRequireUnlock()
    func didAcceptUnlock()
}

class ProfileViewController : BaseController {
    
    weak var delegate : ProfileViewDelegate?
    private var presenter: ProfilePresenter!
    
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    lazy var gradView : GradietView = {
        let view = GradietView()
        view.alpha = 0.85
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private var firstCell : PhotoCell!
    
    private lazy var swipingView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isPagingEnabled = true
        view.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.description())
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private lazy var pageControll : UIPageControl = {
        let view = UIPageControl()
        view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        view.pageIndicatorTintColor = Color.gray.uiColor
        view.currentPageIndicatorTintColor = .white
        return view
    }()
    
    private lazy var listView : ListView = {
        let view = ListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var closeBtn : UIButton = {
        let view = CircleButton()
        view.setImage(#imageLiteral(resourceName: "cancelIcon"), for: .normal)
        view.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.backgroundColor = Color.fadedPurple.uiColorWithAlpha(0.5)
        view.tintColor = .white
        return view
    }()
    
    private lazy var nameLabel : Label = {
        let view = Label()
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return view
    }()
    
    private lazy var distanceLabel: Label = {
        let view = Label()
        view.textColor = Color.fadedPurple.uiColor
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    
    private lazy var buttonContainer: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = 20
        view.axis = .horizontal
        view.alignment = .center
        return view
    }()
    
    private lazy var leftButton : UIButton = {
        let view = UIButton()
        view.backgroundColor = Color.fadedBackground.uiColor
        view.titleLabel?.font =  UIFont.systemFont(ofSize: 14)
        view.setTitle("Unmatch", for: .normal)
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var rightButton : UIButton = {
        let view = UIButton()
        view.backgroundColor = Color.fadedBackground.uiColor
        view.titleLabel?.font =  UIFont.systemFont(ofSize: 14)
        view.setTitle("Unmatch", for: .normal)
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    
    //MARK: constructors
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    

    convenience init(channelUid: String){
        self.init()
        self.presenter = ProfilePresenter(channelUid: channelUid)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func configure() {
        super.configure()
        closeBtn.addTarget(self, action: #selector(didTapCloseBtn), for: .touchUpInside)
        swipingView.dataSource = self
        swipingView.delegate = self
        setupListView()
        layout()
    }
    
    override func reloadView() {
        super.reloadView()
        self.setupPageControll()
        self.swipingView.reloadData()
        self.nameLabel.text = self.presenter.user?.fullName
        self.distanceLabel.text = "\(self.presenter.user?.distance ?? 0)km away"
        self.updateProfileShare()
    }
    
    private func setupPageControll() {
        if self.presenter.numberOfPhotos <= 1 {
            pageControll.isHidden = true
        } else {
            pageControll.numberOfPages = self.presenter.numberOfPhotos
        }
    }
    
    private func setupListView() {
        listView.separatorStyle = .none
        listView.backgroundColor = .clear
        listView.separatorInset  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        listView.cellClassIdentifiers = ["UserProfileCell": UserProfileCell.self]
        listView.cellReuseIdentifier = {
            (indexPath) in
            return "UserProfileCell"
        }
        listView.heightForRow = { _ in
            return 86
        }
        listView.numberOfRows = { [weak self] _ in
            return self?.presenter.numberOfItems ?? 0
        }
        
        listView.parameterForRow = {[weak self] (indexPath) in
            return self?.presenter.settingsItem(atIndexPath: indexPath)
        }
    }
    
    private func layout(){
        view.addSubview(swipingView)
        swipingView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.45)
        }
        
        view.addSubview(gradView)
        gradView.snp.makeConstraints {
            $0.edges.equalTo(swipingView)
        }
        
        view.addSubview(distanceLabel)
        distanceLabel.snp.makeConstraints {
            $0.bottom.equalTo(swipingView.snp.bottom).inset(20)
            $0.left.equalToSuperview().inset(25)
        }
        
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.bottom.equalTo(distanceLabel.snp.top).offset(-5)
            $0.left.equalToSuperview().inset(25)
            $0.width.equalToSuperview().multipliedBy(0.6)
        }
        
        view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints {
            $0.top.equalTo(swipingView.snp.top).inset(25)
            $0.right.equalTo(swipingView.snp.right).inset(25)
            $0.height.width.equalTo(32)
        }
        
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.top.equalTo(swipingView.snp.bottom)
            $0.bottom.left.right.equalToSuperview()
        }
        
        view.addSubview(pageControll)
        pageControll.snp.makeConstraints {
            $0.bottom.equalTo(swipingView.snp.bottom).inset(25)
            $0.right.equalTo(swipingView.snp.right).inset(25)
        }
        
        view.addSubview(buttonContainer)
        buttonContainer.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.07)
            $0.left.right.equalToSuperview().inset(45)
        }
        
        buttonContainer.addArrangedSubview(leftButton)
        leftButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
        }
        
        buttonContainer.addArrangedSubview(rightButton)
        rightButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
        }
    }
    
    @objc private func didTapCloseBtn(){
        self.dismiss(animated: true)
    }
    
    @objc private func didRequireUnlock(){
        self.dismiss(animated: true)
        self.delegate?.didRequireUnlock()
    }
    
    @objc private func didAcceptUnlock(){

        self.dismiss(animated: false)
        self.delegate?.didAcceptUnlock()
    }
    
    private func updateProfileShare() {
        guard let profileShareStatus = self.presenter.profileShareStatus else { return }
        switch profileShareStatus {
        case .notRequested:
            pageControll.isHidden = true
            swipingView.isUserInteractionEnabled = false
            leftButton.backgroundColor = Color.green.uiColor
            leftButton.setTitle("Request", for: .normal)
            rightButton.setTitle("Unmatch", for: .normal)
            leftButton.addTarget(self, action: #selector(didRequireUnlock), for: .touchUpInside)
        case .received:
            pageControll.isHidden = true
            swipingView.isUserInteractionEnabled = false
            leftButton.backgroundColor = Color.green.uiColor
            leftButton.setTitle("Accept", for: .normal)
            rightButton.setTitle("Unmatch", for: .normal)
            leftButton.addTarget(self, action: #selector(didAcceptUnlock), for: .touchUpInside)
        case .pending:
            swipingView.isUserInteractionEnabled = false
            pageControll.isHidden = true
            leftButton.backgroundColor = .white
            leftButton.setTitleColor(.black, for: .normal)
            leftButton.setTitle("Pending", for: .normal)
            rightButton.setTitle("Cancel", for: .normal)
        case .loadingPending:
            swipingView.isUserInteractionEnabled = false
        case .shared:
            pageControll.isHidden = false

            rightButton.setTitle("Unmatch", for: .normal)
            swipingView.isUserInteractionEnabled = true
            leftButton.isHidden = true
        }
    }
}

extension ProfileViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        return self.presenter.numberOfPhotos
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.description(), for: indexPath as IndexPath) as! PhotoCell
        let url = self.presenter.userPhoto(atIndexPath: indexPath)
        cell.setupWith(url: url)
        
        if let profileShareStatus = self.presenter.profileShareStatus,
            profileShareStatus != .shared,
            indexPath.row == 0 {
            cell.blurUp()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: swipingView.frame.width, height: swipingView.frame.height )
    }
}

extension ProfileViewController : ProfileDelegate {

}
