//
//  UserFilterPreferenceBlockView.swift
//  Sparks
//
//  Created by George Vashakidze on 7/26/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

class UserFilterPreferenceBlockView: BaseView {
    
    ///Image of each item in container
    lazy private var itemImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = Image.close.uiImage
        return imageView
    }()
    
    ///Left Title of each item in container
    private var titleLabelLeft : UILabel = {
        var view = UILabel()
        view.contentMode = .center
        view.textColor = .white
        view.font = Font.bold.uiFont(ofSize: 16)
        return view
    }()
    
    ///Right Title of each item in container
    private var titleLabelRight : UILabel = {
        var view = UILabel()
        view.contentMode = .center
        view.textColor = .white
        view.font = Font.bold.uiFont(ofSize: 16)
        return view
    }()
    
    ///Holds all subviews
    lazy private var mainContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = false
        return view
    }()
    
    ///Holds all subviews on the right side on first stack of mainContainerView
    lazy private var subContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = false
        return view
    }()
    
    ///Primary content container view. WIll be used to input data from outside
    lazy private var itemContentContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = false
        return view
    }()
    
    ///Item separator view. Subvview of subContainerView
    lazy private var separatorView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: "#F0F0F0", alpha: 0.05)
        return view
    }()
    
    
    ///This must be set from outside and will be shown as a content
    var primaryContentView: UIView? {
        didSet {
            if let view = self.primaryContentView {
                self.itemContentContainerView.addSubviewWithConstrainedBounds(subview: view)
            }
        }
    }
    
    ///Image to show on the left
    var image: UIImage? {
        didSet {
            self.itemImageView.image = image
        }
    }
    
    ///title to show on the left top
    var titleLeft: String? {
        didSet {
            self.titleLabelLeft.text = titleLeft
        }
    }
    
    ///title to show on the right top
    var titleRight: String? {
        didSet {
            self.titleLabelRight.text = titleRight
        }
    }
    
    override func configure() {
        initLayout()
    }
    
    ///Build Layout
    private func initLayout() {
        mainContainerView.addSubview(itemImageView)
        subContainerView.addSubview(titleLabelLeft)
        subContainerView.addSubview(titleLabelRight)
        subContainerView.addSubview(itemContentContainerView)
        subContainerView.addSubview(separatorView)
        mainContainerView.addSubview(subContainerView)
        addSubviewWithConstrainedBounds(subview: mainContainerView)
        
        itemImageView.snp.makeConstraints {
            $0.left.equalTo(mainContainerView.snp.left).offset(24)
            $0.top.equalTo(mainContainerView.snp.top).offset(24)
            $0.width.height.equalTo(32)
        }
        
        subContainerView.snp.makeConstraints {
            $0.left.equalTo(itemImageView.snp.right).offset(24)
            $0.top.equalTo(mainContainerView.snp.top).offset(24)
            $0.right.equalTo(mainContainerView.snp.right)
            $0.bottom.equalTo(mainContainerView.snp.bottom)
        }
        
        titleLabelLeft.snp.makeConstraints {
            $0.left.equalTo(subContainerView.snp.left)
            $0.centerY.equalTo(itemImageView.snp.centerY)
            $0.height.equalTo(20)
        }
        
        titleLabelRight.snp.makeConstraints {
            $0.right.equalTo(subContainerView.snp.right).offset(-24)
            $0.centerY.equalTo(titleLabelLeft.snp.centerY)
        }
        
        separatorView.snp.makeConstraints {
            $0.left.equalTo(subContainerView.snp.left)
            $0.right.equalTo(subContainerView.snp.right).offset(-24)
            $0.height.equalTo(1)
            $0.bottom.equalTo(subContainerView.snp.bottom)
        }
        
        itemContentContainerView.snp.makeConstraints {
            $0.left.equalTo(subContainerView.snp.left)
            $0.right.equalTo(subContainerView.snp.right).offset(-24)
            $0.top.equalTo(titleLabelLeft.snp.bottom)
            $0.bottom.equalTo(separatorView.snp.top)
        }
        
    }
}
