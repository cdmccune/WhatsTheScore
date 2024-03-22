//
//  GeneralMocks.swift
//  What's The Score
//
//  Created by Curt McCune on 12/30/23.
//

import UIKit
@testable import Whats_The_Score

// MARK: - ViewController

class ViewControllerPresentMock: UIViewController {
    var presentCalledCount = 0
    var presentViewController: UIViewController?
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentCalledCount += 1
        presentViewController = viewControllerToPresent
    }
}


// MARK: - Navigation Controller

class NavigationControllerPushMock: UINavigationController {
    var pushViewControllerCount = 0
    var pushedViewController: UIViewController?
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.pushedViewController = viewController
        pushViewControllerCount += 1
    }
}

class RootNavigationControllerPushMock: RootNavigationController {
    var pushViewControllerCount = 0
    var pushedViewController: UIViewController?
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.pushedViewController = viewController
        pushViewControllerCount += 1
    }
}

class NavigationControllerPopMock: UINavigationController {
    var popViewControllerCount = 0
    
    override func popViewController(animated: Bool) -> UIViewController? {
        popViewControllerCount += 1
        return nil
    }
}


// MARK: - TableView

class TableViewDelegateMock: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    init(cellIdentifier: String) {
        self.cellIdentifier = cellIdentifier
    }
    var cellIdentifier: String
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        return cell
    }
}

class UITableViewReloadDataMock: UITableView {
    var reloadDataCalledCount = 0
    override func reloadData() {
        reloadDataCalledCount += 1
    }
}

class UITableViewReloadRowsMock: UITableView {
    var reloadRowsCalledCount = 0
    var reloadRowsIndexPathArray: [IndexPath]?
    override func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        reloadRowsCalledCount += 1
        reloadRowsIndexPathArray = indexPaths
    }
}

class UITableViewRegisterMock: UITableView {
    var registerCellReuseIdentifiers: [String] = []
    override func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        registerCellReuseIdentifiers.append(identifier)
    }
    
    var registerHeaderFooterIdentifier: String?
    override func register(_ nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) {
        registerHeaderFooterIdentifier = identifier
    }
}


// MARK: - DispatchQueue

class DispatchQueueMainMock: DispatchQueueProtocol {
    
    var asyncAfterCalledCount = 0
    func asyncAfter(deadline: DispatchTime, execute work: @escaping @convention(block) () -> Void) {
        asyncAfterCalledCount += 1
        work()
    }
    
    var asyncCalledCount = 0
    func async(execute work: @escaping @convention(block) () -> Void) {
        asyncCalledCount += 1
        work()
    }
}


// MARK: - Other

class UIViewSafeAreaLayoutFrameMock: UIView {
    init(safeAreaFrame: CGRect) {
        self.privateSafeAreaFrame = safeAreaFrame
        super.init(frame: safeAreaFrame)
    }
    private var privateSafeAreaFrame: CGRect
    override var safeAreaFrame: CGRect {
        privateSafeAreaFrame
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UITextFieldDelegateMock: NSObject, UITextFieldDelegate { }

class TabbarControllerMock: UITabBarController {
    var didSelectCalledCount = 0
    var didSelectTabbarItem: UITabBarItem?
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        didSelectCalledCount += 1
        didSelectTabbarItem = item
    }
}
