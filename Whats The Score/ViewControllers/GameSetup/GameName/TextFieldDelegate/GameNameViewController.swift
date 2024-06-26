//
//  GameNameViewController.swift
//  Whats The Score
//
//  Created by Curt McCune on 4/12/24.
//

import UIKit

class GameNameViewController: UIViewController, Storyboarded {
    
    // MARK: - Outlets
    
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    
    // MARK: - Properties
    
    weak var coordinator: GameSetupCoordinator?
    lazy var textFieldDelegate = GameNameTextFieldDelegate()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueButton.underlineButtonForButtonStates(title: "Continue")
        nameTextField.becomeFirstResponder()
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    
    // MARK: - Private Functions
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        continueButton.isEnabled = nameTextField.text ?? "" != ""
    }
    
    
    // MARK: - IBActions
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        coordinator?.gameNameSet(nameTextField.text ?? "Game")
    }
}
