//
//  RequestsController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 27.08.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import UIKit
import Koloda

class ChannelRequestCell: TableViewCell {
    var channel: Channel?
    
    private lazy var LastMessageLabel : Label = {
        let view = Label()
        view.font = UIFont.systemFont(ofSize: 12, weight: .light)
        view.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var containerView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = Color.fadedBackground.uiColor
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        LastMessageLabel.text = nil
    }
    
    override func setup(){
        self.selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalToSuperview()
            make.bottom.equalTo(-32)
        }
        
        containerView.addSubview(LastMessageLabel)
        LastMessageLabel.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(32)
        }
    }
    
    override func configure(parameter: TableViewCellParameter?, delegate: TableViewCellDelegate?) {
        super.configure(parameter: parameter, delegate: delegate)
        self.channel = parameter as? Channel
    }
}

class ChannelRequestsController: BaseController {
    
    let presenter = ChannelRequestsPresenter()
    override func getPresenter() -> Presenter {
        return presenter
    }
    
    lazy private(set) var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Image.close.uiImage, for: .normal)
        button.addTarget(self, action: #selector(didTapAtCloseButton), for: .touchUpInside)
        return button
    }()
    
    lazy private var cardsView : KolodaView = {
        let view = KolodaView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func configure() {
        super.configure()
        self.view.addSubview(self.cardsView)
        cardsView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(cardsView.snp.width)
        }
        
        self.view.addSubview(closeButton)
        closeButton.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.right.equalToSuperview().inset(30)
            $0.height.equalTo(30)
            $0.width.equalTo(30)
        })
        closeButton.contentMode = .scaleAspectFill
        closeButton.layer.cornerRadius = 15
        closeButton.clipsToBounds = true
        
        setupListView()
    }
    
    @objc func didTapAtCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupListView(){
        
        cardsView.delegate = self
        cardsView.dataSource = self
        
//        listView.backgroundColor = .clear
//        listView.separatorStyle = .none
//        listView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
//        listView.cellClassIdentifiers = [ChannelRequestCell.description(): ChannelRequestCell.self]
//        listView.cellReuseIdentifier = {(indexPath) in return ChannelRequestCell.description() }
//        listView.heightForRow = {(indexPath) in return 150 }
//        listView.sectionCount = ({ return 1 })
//        listView.numberOfRows = {[weak self](section) in return self?.presenter.numbrOfChannels ?? 0 }
//        listView.parameterForRow = {[weak self](indexPath) in
//            let item = self?.presenter.channel(at: indexPath)
//            return item
//        }
//        listView.didSelectRow = {(indexPath) in
////            let conversation = self.presenter.channel(at: indexPath)
////            let chatController = ChatController(channelUid: conversation?.uid)
////            self.navigationController?.pushViewController(chatController, animated: true)
//        }
//
//        listView.didTapEmptyListButton = {[weak self] in
//            let newMessageController = NewMessageController()
//            self?.present(newMessageController, animated: true, completion: nil)
//        }
    }
    
    override func reloadView() {
        super.reloadView()
        //self.cardsView.reloadData()
    }
}

extension ChannelRequestsController: ChannelRequestsPresenterView {
    func reload(deletions: [Int], insertions: [Int], modifications: [Int]) {
        
    }
}

extension ChannelRequestsController: KolodaViewDelegate, KolodaViewDataSource {
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return ImageView(url: self.presenter.channel(at: 0)?.otherUsers.first?.photoUrl)
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return 4
    }
}
