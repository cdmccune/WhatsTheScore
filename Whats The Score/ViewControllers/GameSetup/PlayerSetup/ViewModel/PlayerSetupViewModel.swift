//
//  PlayerSetupViewModel.swift
//  What's The Score
//
//  Created by Curt McCune on 1/3/24.
//

import Foundation

class PlayerSetupViewModel: PlayerSetupViewModelProtocol {
    
    var players: [PlayerSettings] = []
    var dispatchQueue: DispatchQueueProtocol = DispatchQueue.main
    weak var coordinator: GameSetupCoordinator?
    weak var delegate: PlayerSetupViewModelViewProtocol? {
        didSet {
            delegate?.bindViewToViewModel(dispatchQueue: dispatchQueue)
        }
    }
    
    
    // MARK: - Functions
    
    func movePlayerAt(_ sourceRowIndex: Int, to destinationRowIndex: Int) {
        guard players.indices.contains(sourceRowIndex),
              players.indices.contains(destinationRowIndex) else { return }
        
        
        let player = players.remove(at: sourceRowIndex)
        players.insert(player, at: destinationRowIndex)
        delegate?.bindViewToViewModel(dispatchQueue: dispatchQueue)
    }
    
    func addPlayer() {
        coordinator?.showAddPlayerPopover(withPlayerSettings: PlayerSettings(name: "", icon: getRandomIcon()), andDelegate: self)
    }
    
    private func getRandomIcon() -> PlayerIcon {
        let filteredIcons = PlayerIcon.allCases.filter { icon in
            !players.contains { player in
                player.icon == icon
            }
        }
        
        if let filteredRandomIcon = filteredIcons.randomElement() {
            return filteredRandomIcon
        } else if let randomIcon = PlayerIcon.allCases.randomElement() {
            return randomIcon
        } else {
            fatalError("No Icons")
        }
    }
    
    func editPlayerAt(row: Int) {
        guard players.indices.contains(row) else { return }
        coordinator?.showAddPlayerPopover(withPlayerSettings: players[row], andDelegate: self)
    }
    
    func randomizePlayers() {
        players.shuffle()
        delegate?.bindViewToViewModel(dispatchQueue: dispatchQueue)
    }
    
    func deletePlayerAt(_ index: Int) {
        guard players.indices.contains(index) else { return }
        players.remove(at: index)
        delegate?.bindViewToViewModel(dispatchQueue: dispatchQueue)
    }
    
    func playersSetup() {
        coordinator?.playersSetup(players)
    }
}

extension PlayerSetupViewModel: EditPlayerPopoverDelegateProtocol {
    func finishedEditing(_ player: PlayerSettings) {
        
        if let playerIndex = players.firstIndex(of: player) {
            players[playerIndex] = player
        } else {
            players.append(player)
        }
        delegate?.bindViewToViewModel(dispatchQueue: dispatchQueue)
    }
}
