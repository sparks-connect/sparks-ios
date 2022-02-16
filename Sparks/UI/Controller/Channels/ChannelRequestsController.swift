//
//  RequestsController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 27.08.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import UIKit

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
    
    lazy private var listView : ListView = {
        let view = ListView(frame: .zero, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func configure() {
        super.configure()
        self.view.addSubview(self.listView)
        listView.snp.makeConstraints { make in
            make.top.equalTo(32)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-32)
        }
        setupListView()
    }
    
    private func setupListView(){
        listView.backgroundColor = .clear
        listView.separatorStyle = .none
        listView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        listView.cellClassIdentifiers = [ChannelRequestCell.description(): ChannelRequestCell.self]
        listView.cellReuseIdentifier = {(indexPath) in return ChannelRequestCell.description() }
        listView.heightForRow = {(indexPath) in return 150 }
        listView.sectionCount = ({ return 1 })
        listView.numberOfRows = {[weak self](section) in return self?.presenter.numbrOfChannels ?? 0 }
        listView.parameterForRow = {[weak self](indexPath) in
            let item = self?.presenter.channel(at: indexPath)
            return item
        }
        listView.didSelectRow = {(indexPath) in
//            let conversation = self.presenter.channel(at: indexPath)
//            let chatController = ChatController(channelUid: conversation?.uid)
//            self.navigationController?.pushViewController(chatController, animated: true)
        }
        
        listView.didTapEmptyListButton = {[weak self] in
            let newMessageController = NewMessageController()
            self?.present(newMessageController, animated: true, completion: nil)
        }
    }
    
    override func reloadView() {
        super.reloadView()
        self.listView.reloadData()
    }
}

extension ChannelRequestsController: ChannelRequestsPresenterView {
    func reload(deletions: [Int], insertions: [Int], modifications: [Int]) {
        self.listView.update(with: .automatic,
                             section: 0,
                             deletions: deletions.map({ IndexPath(row: $0, section: 0) }),
                             insertions: insertions.map({ IndexPath(row: $0, section: 0) }),
                             modifications: modifications.map({ IndexPath(row: $0, section: 0) }))
    }
}
