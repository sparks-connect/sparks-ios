//
//  PhoneInput.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 7/17/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

class PhoneInput: UIControl {
    
    class PrefixView: UIView {
        
        var country: Country = Country.defaultCountry {
            didSet {
                label.text = country.emojiWithCode
            }
        }
        
        lazy var label: UILabel = {
            let label = UILabel()
            label.font = UIFont.font(for: 14, style: .regular)
            label.textColor = .white
            label.text = country.emojiWithCode
            return label
        }()
        
        lazy var icon: UIImageView = {
            let view = UIImageView(image: #imageLiteral(resourceName: "ic_common_dropdown"))
            view.contentMode = .scaleAspectFit
            view.tintColor = .white
            return view
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.addSubview(label)
            self.addSubview(icon)
            
            icon.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-8)
                make.width.equalTo(8)
                make.height.equalTo(icon.snp.width)
            }
            
            label.snp.makeConstraints { (make) in
                make.left.equalTo(8)
                make.centerY.equalToSuperview()
                make.right.equalTo(icon.snp.left).offset(-8)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private(set) lazy var prefixView: PrefixView = {
        let view = PrefixView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = Color.fadedLighter.uiColor
        return view
    }()
    
    private lazy var input: UITextField = {
        let view = UITextField()
        view.textColor = .white
        view.keyboardType = .phonePad
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 8
        return view
    }()
    
    private(set) var phone = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = Color.fadedBackground.uiColor
        self.layer.cornerRadius = 15
        self.addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
            make.left.equalTo(8)
            make.right.equalTo(-8)
        }
        
        stackView.addArrangedSubview(self.prefixView)
        self.prefixView.snp.makeConstraints { (make) in make.width.equalTo(100) }
        stackView.addArrangedSubview(self.input)
        
        self.prefixView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(prefixClicked)))
        self.input.addTarget(self, action: #selector(textChanged(sender:)), for: .editingChanged)
    }
    
    override func becomeFirstResponder() -> Bool {
        _ = super.becomeFirstResponder()
        return self.input.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        _ = super.resignFirstResponder()
        return self.input.resignFirstResponder()
    }
    
    @objc private func textChanged(sender: UITextField) {
        guard let text = sender.text else { return }
        self.phone = self.prefixView.country.code + text
        self.sendActions(for: .valueChanged)
    }
    
    @objc private func prefixClicked() {
        self.sendActions(for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
