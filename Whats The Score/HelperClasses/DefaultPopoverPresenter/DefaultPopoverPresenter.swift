//
//  DefaultPopoverPresenter.swift
//  Whats The Score
//
//  Created by Curt McCune on 2/6/24.
//

import Foundation
import UIKit

protocol DefaultPopoverPresenterProtocol {
    func setupPopoverCentered(onView view: UIView, withPopover viewController: DismissingPopoverViewController, withWidth width: CGFloat, andHeight height: CGFloat, tapToExit: Bool)
}

class DefaultPopoverPresenter: DefaultPopoverPresenterProtocol {
    
    var delegate: NoAdaptivePresentationStylePopoverPresentationDelegate?
    
    func getCenteredRectWith(onView view: UIView, withWidth width: CGFloat, andHeight height: CGFloat) -> CGRect {
        return CGRect(x: view.bounds.width/2 - width/2, y: view.bounds.height/2 - height/2, width: width, height: height)
    }
    
    func setupPopoverCentered(onView view: UIView, withPopover viewController: DismissingPopoverViewController, withWidth width: CGFloat, andHeight height: CGFloat, tapToExit: Bool = false) {
        
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        viewController.popoverPresentationController?.sourceView = view
        viewController.popoverPresentationController?.sourceRect = getCenteredRectWith(onView: view, withWidth: width, andHeight: height)
        viewController.preferredContentSize = CGSize(width: width, height: height)
        
        delegate = NoAdaptivePresentationStylePopoverPresentationDelegate(tapToExit: tapToExit)
        viewController.popoverPresentationController?.delegate = delegate
        viewController.dismissingDelegate = delegate
        
        let maskView = UIView(frame: view.bounds)
        maskView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.mask = maskView
        delegate?.maskView = maskView
        
        viewController.hideKeyboardWhenTappedAround()
    }
}
