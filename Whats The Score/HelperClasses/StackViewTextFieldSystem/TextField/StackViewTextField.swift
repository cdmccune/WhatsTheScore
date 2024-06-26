//
//  StackViewTextField.swift
//  Whats The Score
//
//  Created by Curt McCune on 2/19/24.
//

import UIKit

class StackViewTextField: DarkModeStyledUITextField {

    init(delegate: StackViewTextFieldDelegateDelegateProtocol, isLast: Bool, index: Int) {
        self.actionDelegate = delegate
        self.index = index
        super.init(frame: CGRectZero)
        self.setupToolbar(isLast: isLast)
        self.setupEditingChangedTarget()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var index: Int
    weak var actionDelegate: StackViewTextFieldDelegateDelegateProtocol?
    
    private func setupEditingChangedTarget() {
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange() {
        actionDelegate?.textFieldValueChanged(forIndex: index, to: self.text ?? "")
    }
    
    private func setupToolbar(isLast: Bool) {
        let toolbar = UIToolbar()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let action = UIBarButtonItem(title: isLast ? "Done" : "Next", style: isLast ? .done : .plain, target: self, action: #selector(toolBarActionTriggered))
        toolbar.items = [flex, action]
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar
    }
    
    @objc private func toolBarActionTriggered() {
        actionDelegate?.textFieldShouldReturn(for: index)
    }
}
