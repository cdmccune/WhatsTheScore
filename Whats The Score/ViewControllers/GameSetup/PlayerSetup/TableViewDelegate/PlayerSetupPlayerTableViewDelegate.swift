//
//  PlayerSetupPlayerTableViewDelegate.swift
//  What's The Score
//
//  Created by Curt McCune on 1/3/24.
//

import Foundation
import UIKit

class PlayerSetupPlayerTableViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    init(playerViewModel: PlayerSetupViewModelProtocol) {
        self.playerViewModel = playerViewModel
    }
    
    var playerViewModel: PlayerSetupViewModelProtocol
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerViewModel.players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerSetupPlayerTableViewCell", for: indexPath) as? PlayerSetupPlayerTableViewCell else {
            fatalError("PlayerSetupPlayerTableViewCell wasn't found")
        }
            
        guard playerViewModel.players.indices.contains(indexPath.row) else {
            cell.setupErrorCell()
            return cell
        }
        
        let player = playerViewModel.players[indexPath.row]
        cell.setupViewPropertiesFor(player: player)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playerViewModel.editPlayerAt(row: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        playerViewModel.movePlayerAt(sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.playerViewModel.deletePlayerAt(indexPath.row)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
