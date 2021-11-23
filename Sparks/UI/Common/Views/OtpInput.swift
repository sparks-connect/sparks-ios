//
//  OtpInput.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 7/20/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

class HiddenTextField: UITextField {
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
}

protocol OtpInputDelegate: class {
    func otpInput(didFill otp: String)
}

class OtpInput: BaseView {
    
    weak var delegate: OtpInputDelegate?
    
    var text: String? {
        didSet {
            self.hiddenInput.text = text
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        _ = super.becomeFirstResponder()
        return self.hiddenInput.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        _ = super.resignFirstResponder()
        return self.hiddenInput.resignFirstResponder()
    }
    
    private lazy var hiddenInput: HiddenTextField = {
        let view = HiddenTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.keyboardType = .numberPad
        view.alpha = 0
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 8
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var labels = [UILabel]()
    
    override func configure() {
        super.configure()
        self.addSubview(hiddenInput)
        self.addSubview(stackView)
        
        hiddenInput.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.equalTo(0)
            make.height.equalTo(0)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        for _ in 1...Consts.Defaults.otpLength {
            let label = newLabel()
            self.labels.append(label)
            let view = newLabelContainer()
            view.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.height.equalToSuperview()
            }
            stackView.addArrangedSubview(view)
        }
        
        hiddenInput.addTarget(self, action: #selector(characterChanged(sender:)), for: .editingChanged)
    }
    
    @objc private func characterChanged(sender: UITextField) {
        guard let text = sender.text else { return }
        
        self.labels.forEach { (label) in
            label.text = ""
        }
        
        for (index, character) in text.enumerated() {


            self.labels[index].text = String(character)
        }
        
        if text.count == self.labels.count {
            self.delegate?.otpInput(didFill: text)
        }
    }
    
    private func newLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.contentScaleFactor = 0.1
        label.textColor = .white
        return label
    }
    
    private func newLabelContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Color.fadedBackground.uiColor
        view.layer.cornerRadius = 16
        return view
    }
}
