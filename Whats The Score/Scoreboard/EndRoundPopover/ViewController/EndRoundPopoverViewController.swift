//
//  EndRoundPopoverViewController.swift
//  Whats The Score
//
//  Created by Curt McCune on 2/16/24.
//

import UIKit

protocol EndRoundPopoverDelegateProtocol {
    func endRound(withChanges changeDictionary: [Player: Int])
}

class EndRoundPopoverViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var playerScrollView: UIScrollView!
    @IBOutlet weak var playerStackView: UIStackView!
    
    // MARK: - Properties
    
    var delegate: EndRoundPopoverDelegateProtocol?
    var players: [Player]?
    var round: Int?
    var playerViewHeight: Int?
    var playerSeparatorHeight: Int?
    var textFields: [UITextField] = []
    var playerScoreChanges: [Int] = []
    
    
    // MARK: - LifeCycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupPlayerStackView()
        playerScoreChanges = Array(repeating: 0, count: players?.count ?? 0)
    }
    
    
    // MARK: - Private Functions
    
    private func setupPlayerStackView() {
        guard let players = players else { return }
        for i in players.indices {
            let textField = StackViewTextField(delegate: self,
                                               isLast: i == players.count - 1,
                                               index: i)
            let textFieldDelegate = StackViewTextFieldDelegate(delegate: self)
            textField.tag = i
            textFields.append(textField)
            
            let singlePlayerStackView = EndRoundPopoverPlayerStackView(player: players[i], textField: textField, textFieldDelegate: textFieldDelegate)
            
            singlePlayerStackView.heightAnchor.constraint(equalToConstant: CGFloat(playerViewHeight ?? 0)).isActive = true
            
            self.playerStackView.addArrangedSubview(singlePlayerStackView)
        }
        
        playerStackView.spacing = CGFloat(playerSeparatorHeight ?? 0)
    }
    
    private func setupViews() {
        if let round {
            roundLabel.text = "Round \(round)"
        } else {
            roundLabel.text = "Round ???"
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func endRoundButtonTapped(_ sender: Any) {
        guard let players,
              players.count == playerScoreChanges.count else {
            return
        }
        
        var returnedDictionary: [Player: Int] = [:]
        players.enumerated().forEach { (index, player) in
            returnedDictionary[player] = playerScoreChanges[index]
        }
        
        delegate?.endRound(withChanges: returnedDictionary)
        self.dismiss(animated: true)
    }
    
    @IBAction func exitButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension EndRoundPopoverViewController: StackViewTextFieldDelegateDelegateProtocol {
    func textFieldValueChanged(forIndex index: Int, to newValue: String?) {
        guard playerScoreChanges.indices.contains(index) else { return }
        playerScoreChanges[index] = Int(newValue ?? "0") ?? 0
    }
    
    func textFieldShouldReturn(for index: Int) {
        guard textFields.indices.contains(index) else { return }
        
        if textFields.indices.contains(index + 1) {
            textFields[index + 1].becomeFirstResponder()
        } else {
            textFields[index].endEditing(true)
        }
    }
    
    func textFieldEditingBegan(index: Int) {
        let textFieldIndex = index
        let completePlayerHeight = (playerViewHeight ?? 0) + (playerSeparatorHeight ?? 0)
        let textfieldY = completePlayerHeight * textFieldIndex
        let bottomOfScrollView = playerScrollView.contentOffset.y + playerScrollView.frame.height
        
        if !(Int(textfieldY) < Int(bottomOfScrollView)) {
            let yCoordinate = Int(textfieldY) - Int(playerScrollView.frame.height) + completePlayerHeight
            let point = CGPoint(x: 0, y: yCoordinate)
            playerScrollView.contentOffset = point
        }
    }
}