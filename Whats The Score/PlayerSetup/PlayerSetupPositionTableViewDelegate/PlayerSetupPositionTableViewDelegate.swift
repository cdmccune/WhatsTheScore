//
//  PlayerSetupPositionTableViewDelegate.swift
//  What's The Score
//
//  Created by Curt McCune on 1/3/24.
//

import Foundation
import UIKit

class PlayerSetupPositionTableViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    init(playerViewModel: PlayerSetupViewModelProtocol) {
        self.playerViewModel = playerViewModel
    }
    
    var playerViewModel: PlayerSetupViewModelProtocol
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerViewModel.game.players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerSetupPositionTableViewCell", for: indexPath) as? PlayerSetupPositionTableViewCell else {
            fatalError("PlayerSetupPositionTableViewCell wasn't found")
        }
        cell.numberLabel.text = String(indexPath.row + 1)
        
        return cell
    }
}
