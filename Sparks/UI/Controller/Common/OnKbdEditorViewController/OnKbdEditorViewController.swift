//
//  OnKbdEditorViewController.swift
//  Sparks
//
//  Created by George Vashakidze on 7/26/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import GrowingTextView

@objc protocol OnKbdEditorViewControllerDelegate {
    @objc optional func onClose(customKey: String?)
    @objc optional func onDone(with text: String?, pickerValue: String?, dateValue: __int64_t, customKey: String?)
    @objc optional func onKbEditorPickerDataSource() -> [String]
    @objc optional func onKbEditorDateValue() -> Int64
    @objc optional func onKbEditorSelectedPickerIndex() -> Int
}

enum OnKbdEditorInputKind {
    case text
    case multi
    case date
    case multiLineText
    
    var isText: Bool {
        return self == .text
    }
    
    var isMultiText: Bool {
        return self == .multiLineText
    }
}

class OnKbdEditorViewController: UIViewController {

    static func createModule(text: String?,
                             viewTitle: String,
                             inputTitle: String,
                             placeholder: String,
                             customKey: String?,
                             delegate: OnKbdEditorViewControllerDelegate) -> OnKbdEditorViewController {
        let controller = OnKbdEditorViewController()
        controller.delegate = delegate
        controller.text = text
        controller.viewTitle = viewTitle
        controller.inputTitle = inputTitle
        controller.placeholder = placeholder
        controller.customKey = customKey
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        return controller
    }
    
    @IBOutlet private weak var inputViewBottom: NSLayoutConstraint!
    @IBOutlet private weak var txInput: UITextField!
    @IBOutlet private weak var txtView: GrowingTextView!

    @IBOutlet private weak var hiddenInput: HiddenTextField!
    
    @IBOutlet private weak var lblViewTitle: UILabel!
    @IBOutlet private weak var lblInputTitle: UILabel!
    
    var inputKind = OnKbdEditorInputKind.text
    
    private weak var delegate: OnKbdEditorViewControllerDelegate?
    private var text: String?
    private var customKey: String?
    private var viewTitle: String!
    private var inputTitle: String!
    private var placeholder: String!
    
    private let datePicker : UIDatePicker = {
        let view = UIDatePicker()
        view.datePickerMode = .date
        if #available(iOS 13.4, *) {
            view.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        view.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: .valueChanged)
        view.setValue(Color.fadedPurple.uiColor, forKey: "textColor")
        return view
    }()
    
    private lazy var picker : UIPickerView = {
        let view = UIPickerView()
        view.dataSource = self
        view.delegate = self
        view.setValue(Color.fadedPurple.uiColor, forKey: "textColor")
        return view
    }()
    
    var input: UIView? {
        switch self.inputKind {
        case .date: return datePicker
        case .multi: return picker
        default:
            return nil
        }
    }
    
    private var selectedIndex: Int? {
        didSet {
            guard let index = self.selectedIndex else { return }
            self.picker.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hiddenInput.inputView = self.input
        self.txInput.text = text
        self.hiddenInput.text = text
        self.hiddenInput.isHidden = (self.inputKind.isText || self.inputKind.isMultiText)
        self.txInput.isHidden = !self.inputKind.isText
        self.txtView.isHidden = !self.inputKind.isMultiText

        self.datePicker.date = self.delegate?.onKbEditorDateValue?().toDate ?? Date()
        
        if let dataSource = self.delegate?.onKbEditorPickerDataSource?(),
            let index = self.delegate?.onKbEditorSelectedPickerIndex?(), index < dataSource.count {
            self.selectedIndex = index
        }
        
        configureInput(input: txInput)
        configureInputView(input: txtView)
        configureInput(input: hiddenInput)
        
        self.lblViewTitle.text = self.viewTitle
        self.lblInputTitle.text = self.inputTitle
    }
    
    private func configureInput(input: UITextField) {
        input.autocorrectionType = .no
        input.autocapitalizationType = .none
        input.placeholder = self.placeholder
        input.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: Color.purple.uiColorWithAlpha(0.6)]
        )
    }
    
    private func configureInputView(input: GrowingTextView) {
        input.autocorrectionType = .no
        input.autocapitalizationType = .none
        input.placeholder = self.placeholder
        input.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: Color.purple.uiColorWithAlpha(0.6)]
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        if self.inputKind.isText {
            self.txInput.becomeFirstResponder()
        }else if self.inputKind.isMultiText{
            self.txtView.becomeFirstResponder()
        }else {
            self.hiddenInput.becomeFirstResponder()
        }
    }

    @IBAction private func onClose() {
        self.view.endEditing(true)
        self.delegate?.onClose?(customKey: customKey)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func datePickerValueChanged(sender: UIDatePicker) {
        self.hiddenInput.text = sender.date.toString()
    }
    
    @IBAction private func onDone() {
        self.view.endEditing(true)
        
        var pickerValue: String? = nil
        var dateValue: __int64_t = 0
        
        let selected = self.picker.selectedRow(inComponent: 0)
        if let pickerSource = self.delegate?.onKbEditorPickerDataSource?(), pickerSource.count > selected {
            pickerValue = pickerSource[selected]
        }
        
        dateValue = Int64(self.datePicker.date.milliseconds)
        
        self.delegate?.onDone?(with: self.inputKind.isMultiText ? self.txtView.text : self.txInput.text, pickerValue: pickerValue, dateValue: dateValue, customKey: customKey)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.inputViewBottom.constant = keyboardHeight
            UIView.animate(withDuration: 0.25) {[weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
}

extension OnKbdEditorViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.delegate?.onKbEditorPickerDataSource?().count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.delegate?.onKbEditorPickerDataSource?()[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.hiddenInput.text = self.delegate?.onKbEditorPickerDataSource?()[row]
    }
}

extension OnKbdEditorViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
