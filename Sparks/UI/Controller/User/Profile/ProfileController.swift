//
//  MyProfileController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 05.08.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import UIKit
import MapKit


class ProfileController: BaseController {
    
    private var mainPhotoUpload = false
    var presenter = ProfilePresenter()
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    override func rightBarButtons() -> [UIBarButtonItem] {
        return self.presenter.isCurrentUser ? [UIBarButtonItem(image: UIImage(named: "side-menu"), style: .plain, target: self, action: #selector(settingsClicked(sender:)))] : []
    }
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.register(MyProfilePhotoCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.register(MyProfileAddPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "addPhotoCell")
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = Color.background.uiColor
        return view
    }()
    
    private lazy var cropper: ImageCropperUtil = {
        let cropper = ImageCropperUtil(viewController: self)
        cropper.delegate = self
        return cropper
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(frame: .zero)
        view.axis = .vertical
        view.distribution = .fill
        return view
    }()
    
    lazy private var labelTitle: Label = {
        let view = Label()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.font(for: 24, style: .bold)
        view.textColor = .white
        return view
    }()
    
    lazy private var profilePhotoContainer: CircleCornerView = {
        let view = CircleCornerView()
        view.layer.borderWidth = 1
        view.layer.borderColor = Color.fadedPurple.cgColor
        view.addSubview(profilePhoto)
        profilePhoto.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        if self.presenter.isCurrentUser {
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(sender:))))
        }
        return view
    }()
    
    lazy private var profilePhoto: CircleUserImageView = {
        let view = CircleUserImageView()
        return view
    }()
    
    lazy private var profileContainerView: UIView = {
        let view = UIView()
        view.addSubview(profilePhotoContainer)
        profilePhotoContainer.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.7)
            make.width.equalTo(profilePhotoContainer.snp.height)
            make.left.equalToSuperview()
        }
        view.addSubview(profileRightContainer)
        profileRightContainer.snp.makeConstraints { make in
            make.left.equalTo(profilePhotoContainer.snp.right)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(tripsRightContainer)
        tripsRightContainer.snp.makeConstraints { make in
            make.left.equalTo(profileRightContainer.snp.right).offset(-32)
            make.centerY.equalToSuperview()
        }
        
        return view
    }()
    
    lazy private var profileRightContainer: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.axis = .vertical
        view.addArrangedSubview(labelConnections)
        view.addArrangedSubview(labelConnectionsTitle)
        view.addTapGesture(target: self, selector: #selector(onConnections))
        return view
    }()
    
    lazy private var tripsRightContainer: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.axis = .vertical
        view.addArrangedSubview(labelTrips)
        view.addArrangedSubview(labelTripsTitle)
        view.addTapGesture(target: self, selector: #selector(onMyTrips))
        return view
    }()
    
    lazy private var labelConnectionsTitle: Label = {
        let view = Label()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.font(for: 17, style: .regular)
        view.textAlignment = .center
        view.textColor = .white
        return view
    }()
    
    lazy private var labelConnections: Label = {
        let view = Label()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.font(for: 20, style: .bold)
        view.textColor = .white
        view.textAlignment = .center
        return view
    }()
    
    lazy private var labelTripsTitle: Label = {
        let view = Label()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.font(for: 17, style: .regular)
        view.textAlignment = .center
        view.textColor = .white
        return view
    }()
    
    lazy private var labelTrips: Label = {
        let view = Label()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.font(for: 20, style: .bold)
        view.textColor = .white
        view.textAlignment = .center
        return view
    }()
    
    lazy private var labelTags: Label = {
        let view = Label()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.font(for: 15, style: .thin)
        view.textColor = .gray
        view.numberOfLines = 0
        
        return view
    }()
    
    lazy private var labelPhotosDesc: Label = {
        let view = Label()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.font(for: 13, style: .thin)
        view.textColor = Color.fadedBackground.uiColor
        view.numberOfLines = 0
        view.textAlignment = .center
        view.text = "🔒 Your photos are visible only for unlocked matches"
        return view
    }()
    
    lazy private var viewDivider: UIView = {
        let view = UIView()
        view.backgroundColor = Color.fadedBackground.uiColor
        return view
    }()
    
    lazy private var editProfileButton: UIButton = {
        let profileEditButton = UIButton()
        profileEditButton.backgroundColor = Color.fadedBackground.uiColor
        profileEditButton.layer.cornerRadius = 16
        profileEditButton.clipsToBounds = true
        profileEditButton.setTitle("Edit Profile", for: .normal)
        profileEditButton.titleLabel?.font = Font.regular.uiFont(ofSize: 14)
        profileEditButton.setTitleColor(Color.lightPurple.uiColor, for: .normal)
        profileEditButton.addTarget(self, action: #selector(onProfileEdit), for: .touchUpInside)
        profileEditButton.isHidden = !self.presenter.isCurrentUser
        return profileEditButton
    }()
    
    private let sectionInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)

    convenience init(presenter: ProfilePresenter){
        self.init()
        self.presenter = presenter
    }
    
    override func configure() {
        super.configure()
        self.navigationItem.title = "Profile"
        layout()
    }
    
    private func layout() {
        
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(self.view.safeAreaInsets.top)
        }
        
        stackView.addArrangedSubview(labelTitle)
        labelTitle.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        stackView.addArrangedSubview(profileContainerView)
        profileContainerView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        var spacer = UIView()
        stackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.height.equalTo(4)
        }
        stackView.addArrangedSubview(labelTags)
        
        spacer = UIView()
        stackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.height.equalTo(16)
        }
        
        stackView.addArrangedSubview(viewDivider)
        viewDivider.snp.makeConstraints { make in
            make.height.equalTo(0.3)
        }
        
        stackView.addArrangedSubview(editProfileButton)
        editProfileButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        spacer = UIView()
        stackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.height.equalTo(16)
        }

        spacer = UIView()
        stackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.height.equalTo(12)
        }
        
       // stackView.addArrangedSubview(labelPhotosDesc)
        
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(4)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func reloadView() {
        super.reloadView()
        self.collectionView.reloadData()
        let user = self.presenter.user
        self.labelTitle.text = (user?.displayName ?? "No Name") + ", " + (user?.ageYear.description ?? "")
        self.profilePhoto.set(user: user, channel: nil)
        let count = self.presenter.numberOfChannels
        self.labelConnections.text = "\(count)"
        self.labelConnectionsTitle.text = count > 1 ? "Matches" : "Match"

        let tripsCount = self.presenter.numberOfTrips
        self.labelTrips.text = "\(tripsCount)"
        self.labelTripsTitle.text = tripsCount > 1 ? "Trips" : "Trip"

        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        self.labelTags.attributedText = NSAttributedString(string: user?.tagsStr ?? "", attributes: [.paragraphStyle: paragraphStyle])
    }
    
    @objc private func profileImageTapped(sender: UITapGestureRecognizer) {
        mainPhotoUpload = true
        let controller = ProfilePhotoAddController()
        controller.modalPresentationStyle = .overFullScreen
        controller.isMainPhoto = mainPhotoUpload
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc private func settingsClicked(sender: UIBarButtonItem) {
        let settings = SettingsViewController()
        self.navigationController?.pushViewController(settings, animated: true)
    }
    
    @objc private func onProfileEdit(sender: UIBarButtonItem) {
        let settings = EditProfileViewController()
        self.navigationController?.pushViewController(settings, animated: true)
    }
    
    @objc private func onConnections(){
        self.tabBarController?.selectedIndex = 1
    }
    
    @objc private func onMyTrips(){
        let controller = MyTripsController(presenter: MyTripsPresenter(user: self.presenter.user))
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    var cell: UICollectionViewCell!
}

extension ProfileController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presenter.isCurrentUser ? self.presenter.numberOfItems + 1 : self.presenter.numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 && self.presenter.isCurrentUser {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addPhotoCell", for: indexPath) as? MyProfileAddPhotoCollectionViewCell else {
                return UICollectionViewCell()
            }
            return cell
        }
        let index = self.presenter.isCurrentUser ? indexPath.item - 1 : indexPath.item
        let convertedIndexPath = IndexPath(item: index, section: indexPath.section)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                            for: indexPath) as? MyProfilePhotoCollectionViewCell
              , let _url = self.presenter.photo(atIndexPath: convertedIndexPath)?.url, let url = URL(string: _url) else {
            return UICollectionViewCell()
        }
        
        cell.setup(url: url, isSelected: self.presenter.selectedIndexPaths.contains(indexPath))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (self.presenter.itemsPerRow + 1)
        let availableWidth = collectionView.frame.size.width - paddingSpace
        let widthPerItem = availableWidth / self.presenter.itemsPerRow
      
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
      return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 && self.presenter.isCurrentUser {
            mainPhotoUpload = false
            let controller = ProfilePhotoAddController()
            controller.isMainPhoto = mainPhotoUpload
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true, completion: nil)
            return
        }
        let index = self.presenter.isCurrentUser ? indexPath.item - 1 : indexPath.item
        let ind = IndexPath(item: index, section: indexPath.section)
        guard let photo = self.presenter.photo(atIndexPath: ind) else { return }
        self.cell = collectionView.cellForItem(at: ind)
        let controller = PhotoViewController(image: photo, shouldDelete: self.presenter.isCurrentUser)
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
}

extension ProfileController: MyProfileView {
    
}


extension ProfileController: UserProfileImageCellDelegate, ImageCropperUtilDelegate, MainHeaderViewDelegate {
    
    func didCropImage(image: UIImage) {
        self.presenter.uploadImage(image: image, isMain: mainPhotoUpload)
    }
    
    func didTapAtIndex(_ index: Int) {
        
    }
    
    func needsImageRefresh() -> Bool {
        return false
    }
    
    func didTapOnActionButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ProfileController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimateTransition(withDuration: 0.25, forTransitionType: .Dismissing, originFrame: (self.cell?.frame)!, collectionView: collectionView)
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
        return AnimateTransition(withDuration: 0.25, forTransitionType: .Presenting, originFrame: (self.cell?.frame)!, collectionView: collectionView)
    }

}

extension ProfileController: PhotoViewControllerDelegate {
    func willDeletePhoto(photo: UserPhoto) {
        self.presenter.deletePhoto(photo: photo)
    }
}
