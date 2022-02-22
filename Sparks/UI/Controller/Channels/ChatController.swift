//
//  ChatListController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 3/8/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

fileprivate extension Message.RequestType {
    
    func currentUserCellClass(collectionView: MessagesCollectionView, indexPath: IndexPath) -> AbstractCustomCell {
        switch self{
        case .shareAccepted: return collectionView.dequeueReusableCell(AcceptCell.self, for: indexPath)
        case .shareRejected: return collectionView.dequeueReusableCell(CurrentUserDeclineCell.self, for: indexPath)
        case .shareRequested: return collectionView.dequeueReusableCell(CurrentUserRequestCell.self, for: indexPath)
        }
    }
    func recipientUserCellClass(collectionView: MessagesCollectionView, indexPath: IndexPath) -> AbstractCustomCell {
        switch self {
        case .shareAccepted: return collectionView.dequeueReusableCell(AcceptCell.self, for: indexPath)
        case .shareRejected: return collectionView.dequeueReusableCell(RecipientDeclineCell.self, for: indexPath)
        case .shareRequested: return collectionView.dequeueReusableCell(RecipientRequestCell.self, for: indexPath)
        }
    }
}

class ChatController: MessagesViewController, MessagesDataSource {
    
    private struct ChatControllerProps {
        static let navbarCustomHeight : CGFloat = 90
    }
    
    private var isLoading = false
    private var presenter : ChatPresenter!
    
    func getPresenter() -> Presenter {
        return self.presenter
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var chatNavBarView: ChatNavBarView   = ChatNavBarView()
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    
    //MARK: constructors
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(channelUid: String?){
        self.init()
        if let channel = channelUid {
            self.presenter = ChatPresenter(channelID: channel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: life cycle
    
    override func viewDidLoad() {
        configureNavBar()
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
        messagesCollectionView.register(CurrentUserRequestCell.self)
        messagesCollectionView.register(CurrentUserDeclineCell.self)
        messagesCollectionView.register(RecipientRequestCell.self)
        messagesCollectionView.register(RecipientDeclineCell.self)
        messagesCollectionView.register(AcceptCell.self)
        super.viewDidLoad()
        
        self.presenter.attach(this: self)
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.chatNavBarView.removeFromSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        main(block: {
            self.scrollToBottom()
        }, after: 0.3)
    }
    
    // MARK: - Configuration
    
    private func configureNavBar(){
        self.chatNavBarView.delegate = self
        self.chatNavBarView.hasAction = self.presenter.channel?.isAccepted == true
        self.chatNavBarView.frame.size = CGSize(width: self.view.frame.size.width, height: ChatControllerProps.navbarCustomHeight)
        self.navigationController?.view.addSubview(self.chatNavBarView)
    }
    
    // MARK: - MessagesDataSource
    
    private func configureMessageCollectionView() {
        messagesCollectionView.backgroundColor = Color.background.uiColor
        
        messagesCollectionView.messagesDataSource      = self
        messagesCollectionView.messagesLayoutDelegate  = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.messagesCollectionViewFlowLayout.textMessageSizeCalculator.incomingMessageLabelInsets = UIEdgeInsets(top: 15, left: 16, bottom: 14, right: 16)
        messagesCollectionView.messagesCollectionViewFlowLayout.textMessageSizeCalculator.outgoingMessageLabelInsets = UIEdgeInsets(top: 15, left: 16, bottom: 14, right: 16)
        
        messagesCollectionView.contentInset = UIEdgeInsets(top: ChatControllerProps.navbarCustomHeight, left: 0, bottom: 0, right: 0)
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        
        layout?.setMessageOutgoingAvatarSize(.zero)
        
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        
        // Set outgoing avatar to overlap with the message bubble
        layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 1, left: 18, bottom: 1, right: 0)))
        layout?.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: 1, left: -18, bottom: 1, right: 18))
        
        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
    }
    
    
    private func isLastSectionVisible() -> Bool {
        
        guard !presenter.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: presenter.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    @objc private func loadMoreMessages(){
        self.presenter.fetchHistory()
    }
    
    // MARK: - Input bar
    
    private func configureMessageInputBar() {
        
        messageInputBar.delegate = self
        messageInputBar.isTranslucent = false
        messageInputBar.separatorLine.isHidden = true
        
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        messageInputBar.inputTextView.placeholder = "Type a message"
        
        messageInputBar.padding.left  = 35
        messageInputBar.padding.right = 35
        
        messageInputBar.inputTextView.textColor = .white
        messageInputBar.backgroundView.backgroundColor = Color.background.uiColor
        messageInputBar.inputTextView.backgroundColor = Color.lightBackground.uiColor
        
        messageInputBar.inputTextView.layer.cornerRadius = 18
        messageInputBar.inputTextView.layer.masksToBounds = true
        configureInputBarItems()
    }
    
    private func configureInputBarItems() {
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "sendIcon")
        
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.layer.cornerRadius   = 15
        
        messageInputBar.middleContentViewPadding.right  = -38
        messageInputBar.middleContentViewPadding.bottom = 8
        let charCountButton = InputBarButtonItem()
        let bottomItems = [.flexibleSpace, charCountButton]
        
        messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
        
        // This just adds some more flare
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = .clear
                })
        }.onDisabled { item in
            UIView.animate(withDuration: 0.3, animations: {
                item.imageView?.backgroundColor = .clear
            })
        }
    }
    
    // MARK: - Helpers
    
    func currentSender() -> SenderType {
        return User.current ?? User()
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return presenter.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return presenter.messages?[indexPath.section] ?? Message()
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section == (presenter.count - 1) {
            let dateString =  message.sentDate.toRelativeDateString()
            let attributes = [
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2),
                NSAttributedString.Key.foregroundColor : UIColor.gray
            ]
            return NSAttributedString(string: dateString, attributes: attributes)
        }
        return NSAttributedString.init()
        
    }
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return (isMessageSentLongEnoughAgo(at: indexPath, hours: 3) && !isPreviousMessageSameSender(at: indexPath)) || indexPath.section == 0
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return presenter.messages?[indexPath.section].user?.uid == presenter.messages?[indexPath.section - 1].user?.uid
    }
    
    private func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < presenter.count else { return false }
        return presenter.messages?[indexPath.section].user?.uid == presenter.messages?[indexPath.section + 1].user?.uid
    }
    
    private func isMessageSentLongEnoughAgo(at indexPath: IndexPath, hours: Int) -> Bool{
        
        guard indexPath.section - 1 >= 0 else { return false }
        let hoursInMilliseconds = hours * Consts.MillisecodsInUnit.hour
        
        let messageSendDate = presenter.messages?[indexPath.section].sentDate.milliseconds ?? 0
        let prevMessageSendDate = presenter.messages?[indexPath.section - 1].sentDate.milliseconds ?? 0
        if messageSendDate - prevMessageSendDate >= hoursInMilliseconds {
            return true
        }
        return false
        
    }
    
    // MARK: - UICollectionViewDataSource
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("nil data source for messages")
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        if case .custom(let body) = message.kind {
            
            guard let body = body as? [String: Any] else {
                return super.collectionView(collectionView, cellForItemAt: indexPath )
            }
            
            if let _customCellRequestType = body[Consts.PubNub.kMessageBodyRequestType] as? String,
                let customCellRequestType = Message.RequestType.init(rawValue: _customCellRequestType) {
                let cell : AbstractCustomCell!
                
                if message.sender.senderId == User.current?.uid {
                    cell = customCellRequestType.currentUserCellClass(collectionView: messagesCollectionView, indexPath: indexPath)
                }else {
                    cell = customCellRequestType.recipientUserCellClass(collectionView: messagesCollectionView, indexPath: indexPath)
                }
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                
                return cell
            } else {
                return messagesCollectionView.dequeueReusableCell(AcceptCell.self, for: indexPath)
            }
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    // MARK: - MessagesDataSource
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isTimeLabelVisible(at: indexPath) {
            return  NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
 
    private var displayed = false
    private func displayAcceptRejectAlertIfNeeeded() {
        guard let channel = self.presenter.channel else { return }
        if !channel.isAccepted && !displayed {
            
            let user = channel.otherUsers.first?.displayName ?? ""
            let message = "Click 'Accept' to start chat or click 'Decline' to discard the request. \nYou won't be able to see each others photos until you both agree on unlock."
            let controller = UIAlertController(title: "\(user) wants to connect", message: message, preferredStyle: .actionSheet)
            let acceptButton = UIAlertAction(title: "Accept", style: .default, handler: {(action) in
                self.presenter.accept()
            })
            
            let rejectButton = UIAlertAction(title: "Decline", style: .destructive, handler: {(action) in
                self.presenter.reject()
            })
            
            controller.addAction(acceptButton)
            controller.addAction(rejectButton)
            self.displayed = true
            self.present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - Text Messages

extension ChatController: MessagesDisplayDelegate {
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .white
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url]
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.messageSender : UIColor.messageReceiver
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .custom { view in
            switch view.frame.width {
            case  0...45:
                view.layer.cornerRadius = 20
            default:
                view.layer.cornerRadius = 24
            }
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }
}

// MARK: - MessageInputBarDelegate

extension ChatController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        let messageText = inputBar.inputTextView.components.first as? String
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
        
        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Type a Message"
                
                if let messageText = messageText {
                    self?.presenter.send(text: messageText)
                }
            }
        }
    }
}

extension ChatController : ChatNavBarViewDelegate {
    func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapProfile() {
        guard let channel = presenter.channel else { return }
        _ = self.presenter.checkProfileShareStatus()
        let profileViewController = OldProfileViewController(channelUid: channel.uid)
        profileViewController.delegate = self
        present(profileViewController, animated: true, completion: nil)
    }
    
    func didTapActionButton() {
        self.presenter.didRequireChannelchange()
    }
}

extension ChatController : ChatViewDelegate {
    
    func presentUnlockRequest() {
        let controller = UnlockRequestController(nibName: nil, bundle: nil)
        controller.modalPresentationStyle = .overFullScreen
        controller.delegate = self.presenter
        present(controller, animated: false, completion: nil)
    }
    
    func needToCongrat() {
        //View has to be implemented
    }
    
    func updateNavBar() {
        self.chatNavBarView.setupChannel(channel: self.presenter.channel)
        self.chatNavBarView.set(state: self.presenter.currentUserShareState)
    }
    
    
    func messageAdded(message: [Message]) {
        self.messagesCollectionView.reloadData()
    }
    
    func updateSection(_ section: Int, deletions: [Int], insertions: [Int], modifications: [Int]) {
        self.reloadView()
    }
    
    
    func scrollToBottom() {
        self.messagesCollectionView.scrollToBottom(animated: false)
    }
    
    func willDisappear() {}
    func willAppear() {}
    func notifyError(message: String, okAction: (() -> Void)?) {}
    
    
    func reloadView() {
        self.messagesCollectionView.reloadData()
        self.refreshControl.endRefreshing()
        self.displayAcceptRejectAlertIfNeeeded()
    }
    
    func popScreen() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func refreshFinished() {
        self.refreshControl.endRefreshing()
    }
    
    func channelAccepted() {
        
    }
    
    func channelRejected() {
        // TODO: Display message
        self.navigationController?.popViewController(animated: true)
    }
}

extension ChatController: ProfileViewDelegate {
    func didAcceptUnlock() {
        self.presentUnlockRequest()
    }
    
    func didRequireUnlock() {
        self.presenter.didRequireChannelchange()
    }
    
    
}

extension ChatController: MessageLabelDelegate {
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
}
