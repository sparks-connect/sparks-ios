//
//  DiscoverViewController.swift
//  Sparks
//
//  Created by George Vashakidze on 4/14/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import VerticalCardSwiper
import RxSwift

class DiscoverViewController: BaseController, DiscoverView, UITextFieldDelegate {
    
    private let presenter = DiscoverPresenter()
    override func getPresenter() -> Presenter {
        return presenter
    }
    
    lazy private(set) var cardSwiper: VerticalCardSwiper = {
        let view = VerticalCardSwiper()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private(set) var chatInput: UITextField = {
        let tf = UITextField()
        tf.delegate = self
        tf.backgroundColor = .clear
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.autocapitalizationType = .none
        tf.keyboardAppearance = .dark
        tf.font = Font.regular.uiFont(ofSize: 14)
        tf.textColor = .white
        tf.tintColor = .white
        tf.attributedPlaceholder = NSAttributedString(string: "Type a message",
                                                      attributes: [NSAttributedString.Key.foregroundColor: Color.lightPurple.uiColor])
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    lazy private(set) var sendButton: UIButton = {
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setImage(Image.sendMessagePurple.uiImage, for: .normal)
        sendButton.addTarget(self, action: #selector(onSend), for: .touchUpInside)
        return sendButton
    }()
    
    lazy private(set) var kbdContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.buttonColor.uiColor
        view.layer.cornerRadius = 22
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private(set) var emptyStateViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private(set) var emptyStateImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "ic_send_ballons")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy private(set) var emptyStateTitleLabel: Label = {
        let view = Label()
        view.font = Font.bold.uiFont(ofSize: 32)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.text = "No Sparks\nRecieved"
        view.textAlignment = .center
        view.numberOfLines = 0
        return view
    }()
    
    lazy private(set) var emptyStateSubTitleLabel: Label = {
        let view = Label()
        view.font = Font.regular.uiFont(ofSize: 14)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = Color.lightPurple.uiColor
        view.text = "Spin and get more than swipes\nor you can enjoy by sending sparks."
        view.textAlignment = .center
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var panRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    
    private lazy var skipButton: ActionButton = {
        let button = ActionButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Decline", for: .normal)
        button.setTitleColor(Color.lightPurple.uiColor, for: .normal)
        button.backgroundColor = Color.buttonColor.uiColor
        button.setBackgroundColor(Color.buttonColor.uiColor, forState: .normal)
        button.layer.borderWidth = 0
        button.addTarget(self, action: #selector(onSkipButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var replyButton : ArrowButton = {
        let view = ArrowButton(image: nil, labelText: "Reply")
        view.imageLabel.setTintColor(.white)
        view.setTitleColor(.white, for: .normal)
        view.backgroundColor = Color.purple.uiColor
        view.imageLabel.setTextFont(Font.medium.uiFont(ofSize: 14))
        view.layer.borderWidth = 0
        view.addTarget(self, action: #selector(onReplyButton), for: .touchUpInside)
        return view
    }()
    
    private let headerView = MainHeaderView()
    private let disposeBag = DisposeBag()
    private var keyboardIsOpen: Bool = false
    private var lastContentOffset: CGFloat = 0
    private var isSwipedDown: Bool = false
    
    override func configure() {
        super.configure()
        view.addSubview(headerView)
        
        view.addSubview(emptyStateViewContainer)
        emptyStateViewContainer.addSubview(emptyStateImageView)
        emptyStateViewContainer.addSubview(emptyStateTitleLabel)
        emptyStateViewContainer.addSubview(emptyStateSubTitleLabel)
        
        headerView.delegate = self
        headerView.title = "Discover"
        headerView.image = Image.profile.uiImage
        headerView.imageUrl = User.current?.photoUrl
        headerView.snp.makeConstraints {
            $0.left.equalTo(view.snp.left)
            $0.right.equalTo(view.snp.right)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.height.equalTo(60)
        }
        
        emptyStateViewContainer.snp.makeConstraints({
            $0.top.equalTo(headerView.snp.bottom).offset(82)
            $0.centerX.equalTo(headerView.snp.centerX)
            $0.width.equalTo(234)
            $0.height.equalTo(322)
        })
        emptyStateImageView.snp.makeConstraints({
            $0.left.right.top.equalTo(0)
            $0.centerX.equalTo(headerView.snp.centerX)
        })
        emptyStateTitleLabel.snp.makeConstraints({
            $0.top.equalTo(emptyStateImageView.snp.bottom).offset(16)
            $0.centerX.equalTo(emptyStateImageView.snp.centerX)
        })
        emptyStateSubTitleLabel.snp.makeConstraints({
            $0.top.equalTo(emptyStateTitleLabel.snp.bottom).offset(12)
            $0.centerX.equalTo(emptyStateTitleLabel.snp.centerX)
        })
        
        cardSwiper.visibleNextCardHeight = 0
        cardSwiper.isStackOnBottom = true
        cardSwiper.isSideSwipingEnabled = false
        cardSwiper.stackedCardsCount = 2
        cardSwiper.topInset = 0
        cardSwiper.sideInset = 0
        
        view.addSubview(cardSwiper)
        cardSwiper.snp.makeConstraints{
            $0.top.equalTo(headerView.snp.bottom).offset(52)
            $0.height.equalTo(UIScreen.main.bounds.height / 2.32)
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        
        cardSwiper.delegate = self
        cardSwiper.datasource = self
        
        // register cardcell for storyboard use
        cardSwiper.register(CardSwiperCell.self, forCellWithReuseIdentifier: "CardSwiperCell")
        
        let addFileIconView = UIButton()
        addFileIconView.translatesAutoresizingMaskIntoConstraints = false
        addFileIconView.backgroundColor = .white
        addFileIconView.setImage(Image.attachFileToChat.uiImage, for: .normal)
        addFileIconView.layer.cornerRadius = 10
        
        kbdContainer.addSubview(addFileIconView)
        addFileIconView.snp.makeConstraints{
            $0.width.height.equalTo(20)
            $0.left.equalTo(12)
            $0.centerY.equalTo(kbdContainer.snp.centerY)
        }
        
        kbdContainer.addSubview(chatInput)
        chatInput.snp.makeConstraints{
            $0.left.equalTo(addFileIconView.snp.right).offset(12)
            $0.centerY.equalTo(kbdContainer.snp.centerY)
        }
        
        
        kbdContainer.addSubview(sendButton)
        sendButton.snp.makeConstraints{
            $0.width.height.equalTo(24)
            $0.right.equalTo(-12)
            $0.centerY.equalTo(kbdContainer.snp.centerY)
        }
        
        view.addSubview(kbdContainer)
        kbdContainer.alpha = 0
        kbdContainer.snp.makeConstraints{
            $0.bottom.equalToSuperview()
            $0.height.equalTo(44)
            $0.right.left.equalToSuperview().inset(24)
        }
        
        view.addSubview(skipButton)
        skipButton.snp.makeConstraints{
            $0.top.equalTo(cardSwiper.snp.bottom).offset(0)
            $0.height.equalTo(60)
            $0.width.equalTo(120)
            $0.centerX.equalTo(view.snp.centerX).offset(-71.5)
        }
        
        view.addSubview(replyButton)
        replyButton.snp.makeConstraints{
            $0.top.equalTo(cardSwiper.snp.bottom).offset(0)
            $0.height.equalTo(60)
            $0.width.equalTo(120)
            $0.centerX.equalTo(view.snp.centerX).offset(71.5)
        }
        
        RxKeyboard
            .instance
            .visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                if keyboardVisibleHeight > 0 {
                    self?.keyboardIsOpen = true
                    self?.cardSwiper.snp.updateConstraints { (make) in
                        make.top.equalTo(self!.headerView.snp.bottom).offset(16)
                    }
                    self?.kbdContainer.snp.updateConstraints { (make) in
                        make.bottom.equalToSuperview().inset(keyboardVisibleHeight + 24)
                    }
                } else {
                    self?.keyboardIsOpen = false
                    self?.cardSwiper.snp.updateConstraints { (make) in
                        make.top.equalTo(self!.headerView.snp.bottom).offset(52)
                    }
                    self?.kbdContainer.snp.updateConstraints { (make) in
                        make.bottom.equalToSuperview()
                    }
                }
                UIView.animate(withDuration: 0.25) {
                    self?.view.layoutIfNeeded()
                }
            }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(authorizationChanged),
                                               name: Consts.Notifications.didChangeLocationPermissions,
                                               object: nil)
    }
    
    override func didAppear() {
        super.didAppear()
        displayLocationControllerIfNeeded()
    }
    
    private func displayLocationControllerIfNeeded() {
        if !LocationManager.sharedInstance.isLocationServiceEnabled() {
            let controller = LocationEnableController()
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    override func reloadView() {
        super.reloadView()
        setupEmptyState()
        self.cardSwiper.reloadData()
        _ = self.cardSwiper.scrollToCard(at: self.presenter.numberOfChannels - 1, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = self.cardSwiper.scrollToCard(at: self.presenter.numberOfChannels - 1, animated: false)
    }
    
    @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocity(in: self.cardSwiper)
        if velocity.x != 0 {
            return
        }
        if case .Down = recognizer.verticalDirection(target: cardSwiper) {
            hideKbd()
        } else {
            
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        setupSendButtonState()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= FirebaseConfigManager.shared.maxCharacterCount
    }
    
    private func hideKbd() {
        UIView.animate(withDuration: 0.25) {
            self.chatInput.resignFirstResponder()
            self.kbdContainer.alpha = 0
            self.replyButton.alpha = 1
            self.skipButton.alpha = 1
        }
        self.chatInput.text = ""
        cardSwiper.verticalCardSwiperView.isScrollEnabled = true
        cardSwiper.removeGestureRecognizer(panRecognizer)
    }
    
    @objc private func onReplyButton() {
        if self.presenter.numberOfChannels > 0 {
            onReply()
        } else {
            //TODO:
        }
    }
    
    @objc private func onSkipButton() {
        if self.presenter.numberOfChannels > 0 {
            self.presenter.reject(index: self.presenter.numberOfChannels - 1)
        } else {
            //TODO:
        }
    }
    
    private func setupSendButtonState() {
        let count = chatInput.text?.count ?? 0
        self.sendButton.alpha = count > 0 ? 1 : 0.2
        self.sendButton.isEnabled = count > 0
    }
    
    private func setupEmptyState() {
        let isEmpty = self.presenter.numberOfChannels == 0
        self.emptyStateViewContainer.alpha = isEmpty ? 1 : 0
        if isEmpty {
            self.replyButton.setText("Premium")
            self.replyButton.setImage(nil)
            self.skipButton.setTitle("Spin and win", for: .normal)
        } else {
            self.replyButton.setText("Reply")
            self.replyButton.setImage(#imageLiteral(resourceName: "lightArrowIcon"))
            self.skipButton.setTitle("Decline", for: .normal)
        }
    }
    
    private func onReply() {
        setupSendButtonState()
        cardSwiper.verticalCardSwiperView.isScrollEnabled = false
        UIView.animate(withDuration: 0.25) {
            self.kbdContainer.alpha = 1
            self.replyButton.alpha = 0
            self.skipButton.alpha = 0
            self.chatInput.becomeFirstResponder()
        }
        cardSwiper.addGestureRecognizer(panRecognizer)
    }
    
    @objc private func onSend() {
        guard let text = chatInput.text, text.count > 0 else { return }
        self.presenter.acceptAndSend(with: self.presenter.numberOfChannels - 1, and: text)
        self.hideKbd()
    }
    
    @objc private func authorizationChanged(notification: Notification) {
        main {
            self.displayLocationControllerIfNeeded()
        }
    }
}

extension DiscoverViewController: MainHeaderViewDelegate {
    func didTapOnActionButton() {
        
    }
}

extension DiscoverViewController: VerticalCardSwiperDelegate, VerticalCardSwiperDatasource {
    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
        if let cardCell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "CardSwiperCell", for: index) as?
            CardSwiperCell, let channel = self.presenter.channel(atIndexPath: IndexPath(item: index, section: 0)) {
            cardCell.configure(channel: channel)
            return cardCell
        }
        return CardCell()
    }
    
    func sizeForItem(verticalCardSwiperView: VerticalCardSwiperView, index: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 48, height: UIScreen.main.bounds.height / 2.32)
    }
    
    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
        return self.presenter.numberOfChannels
    }
    
    func didScroll(verticalCardSwiperView: VerticalCardSwiperView) {
        if (self.lastContentOffset > verticalCardSwiperView.contentOffset.y) {
            isSwipedDown = true
        }
        else if (self.lastContentOffset < verticalCardSwiperView.contentOffset.y) {
            isSwipedDown = false
        }
        
        // update the new position acquired
        self.lastContentOffset = verticalCardSwiperView.contentOffset.y
        
        let heightPerItem: CGFloat = UIScreen.main.bounds.height / 2.32
        let index = Int(verticalCardSwiperView.contentOffset.y / verticalCardSwiperView.bounds.size.height)
        let lastItemIndex = self.presenter.numberOfChannels - 1
        if index == lastItemIndex && verticalCardSwiperView.contentOffset.y - (heightPerItem * CGFloat(lastItemIndex)) > 15 {
            return
        }
        
        let startY = (heightPerItem * CGFloat(index))
        let current = verticalCardSwiperView.contentOffset.y - startY
        
        if let cell = verticalCardSwiperView.cellForItem(at: IndexPath(row: index + 1, section: 0)) as? CardSwiperCell {
            cell.contentView.alpha = current / heightPerItem
        }
    }
    
    func didEndScroll(verticalCardSwiperView: VerticalCardSwiperView) {
        
        guard isSwipedDown else { return }
        
        let heightPerItem: CGFloat = UIScreen.main.bounds.height / 2.32
        
        let page = floor((verticalCardSwiperView.contentOffset.y - heightPerItem / 2) / heightPerItem) + 1
        
        print("page ", page, " index ", self.presenter.numberOfChannels - 1, " y ", verticalCardSwiperView.contentOffset.y)
        
        let lastIndex = self.presenter.numberOfChannels - 1
        if lastIndex == Int(page) + 1 {
            verticalCardSwiperView.isUserInteractionEnabled = false
            verticalCardSwiperView.performBatchUpdates({ [weak self] in
                self?.presenter.reject(index: lastIndex)
                }, completion: { _ in
                    verticalCardSwiperView.collectionViewLayout.invalidateLayout()
                    verticalCardSwiperView.isUserInteractionEnabled = true
            })
        }
    }
    
}
