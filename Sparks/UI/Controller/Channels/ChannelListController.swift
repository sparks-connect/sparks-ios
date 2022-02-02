//
//  ChatListController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 3/8/20.
//  Copyright © 2020 Sparks. All rights reserved.
//
import UIKit
import SnapKit
import SDWebImage

class ChannelListController: BaseController, TableViewCellDelegate {
    //MARK: properties
    
    init(_ criteria: ChannelCriteria = .matches) {
        super.init(nibName: nil, bundle: nil)
        self.presenter = ChannelsPresenter(criteria)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var presenter: ChannelsPresenter!
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    private let channelsEmptyListView = ChannelsEmptyListView()
    
    lazy private var listView : ListView = {
        let view = ListView(frame: .zero, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var labelNoMatchesYet : Label = {
        let view = Label()
        view.font = UIFont.font(for: 28, style: .bold)
        view.textColor = .white
        view.numberOfLines = 0
        view.text = "No matches yet"
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var badgeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: -10, width: 20, height: 20))
        label.layer.borderColor = UIColor.clear.cgColor
        label.layer.borderWidth = 2
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.font = UIFont.font(for: 10, style: .regular)
        label.textColor = .white
        label.backgroundColor = .red
        label.isHidden = true
        return label
    }()
    
    override func rightBarButtons() -> [UIBarButtonItem] {
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 18, height: 16))
        rightButton.setBackgroundImage(#imageLiteral(resourceName: "ic_bell"), for: .normal)
        rightButton.tintColor = .white
        rightButton.addTarget(self, action: #selector(requestsClicked), for: .touchUpInside)
        rightButton.addSubview(badgeLabel)

        // Bar button item
        return [UIBarButtonItem(customView: rightButton)]
    }
    
    //MARK: Lifecycle
    override func configure() {
        super.configure()
        self.navigationItem.title = "Sparks"
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(authorizationChanged),
                                               name: Consts.Notifications.didChangeLocationPermissions,
                                               object: nil)
        layout()
        setupListView()
    }
    
    override func willAppear() {
        super.willAppear()
        view.backgroundColor = Color.background.uiColor
        listView.reloadData()
        
        if !LocationManager.sharedInstance.isLocationServiceEnabled() {
            let controller = LocationEnableController()
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true, completion: nil)
        }
        
        let controller = CreateTripController()
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
        
        addProfilePic()
    }
    
    override func reloadView() {
        super.reloadView()
        self.labelNoMatchesYet.isHidden = self.presenter.numberOfChannels > 0
        self.listView.isHidden = self.presenter.numberOfChannels == 0
        self.badgeLabel.isHidden = self.presenter.recievedRequestsCount == 0
        self.badgeLabel.text = "\(self.presenter.recievedRequestsCount)"
        listView.reloadData()
    }
    //MARK: Private functinos
    private func layout(){
        
        view.addSubview(labelNoMatchesYet)
        labelNoMatchesYet.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalTo(32)
            make.right.equalTo(-32)
        }
        
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupListView(){
        listView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        listView.backgroundColor = UIColor.init(hex: "#1f1b24")
        listView.cellClassIdentifiers = [ChannelCell.description(): ChannelCell.self]
        listView.cellReuseIdentifier = {(indexPath) in return ChannelCell.description() }
        listView.heightForRow = {(indexPath) in return 86 }
        listView.sectionCount = ({ return 1 })
        listView.numberOfRows = {[weak self](section) in return self?.presenter.numberOfChannels ?? 0 }
        listView.cellDelegate = {(indexPath) in return self }
        listView.parameterForRow = {[weak self](indexPath) in return self?.presenter.channel(atIndexPath: indexPath) }
        listView.didSelectRow = {[weak self](indexPath) in
            let conversation = self?.presenter.channel(atIndexPath: indexPath)
            let chatController = ChatController(channelUid: conversation?.uid)
            self?.navigationController?.pushViewController(chatController, animated: true)
        }
        
        listView.didTapEmptyListButton = {[weak self] in
            let newMessageController = NewMessageController()
            self?.present(newMessageController, animated: true, completion: nil)
        }
    }
    
    private func addProfilePic() {
        if LocationManager.sharedInstance.isLocationServiceEnabled() && User.current?.isMissingPhoto == true {
            let controller = ProfilePhotoAddController()
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @objc private func authorizationChanged(notification: Notification) {
        main {
            self.addProfilePic()
        }
    }
    
    @objc private func requestsClicked() {
        let channelList = ChannelListController(.allRecievedRequests)
        self.navigationController?.pushViewController(channelList, animated: true)
    }
}
extension ChannelListController: ConversationsView {
    func reloadView(atIndexPath indexPath: IndexPath) {
        listView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func updateSection(_ section: Int, deletions: [Int], insertions: [Int], modifications: [Int]) {
        listView.updateSection(0, with: .automatic, deletions: deletions, insertions: insertions, modifications: modifications)
    }
    
    func push(uid: String, after: Double){
        main(block: {
            self.navigationController?.popToRootViewController(animated: false)
            let chatController = ChatController(channelUid: uid)
            self.navigationController?.pushViewController(chatController, animated: false)
        }, after: after)
    }
    
    func updateRecievedRequestsCount() {
        self.badgeLabel.isHidden = self.presenter.recievedRequestsCount == 0
        self.badgeLabel.text = "\(self.presenter.recievedRequestsCount)"
    }
}

