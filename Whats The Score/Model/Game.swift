//
//  Game.swift
//  What's The Score
//
//  Created by Curt McCune on 12/30/23.
//

import Foundation

protocol GameProtocol {
    var gameType: GameType { get set }
    var gameEndType: GameEndType { get set }
    var numberOfRounds: Int { get set }
    var currentRound: Int { get set }
    var endingScore: Int { get set }
    var players: [PlayerProtocol] { get set }
    var winningPlayers: [PlayerProtocol] { get }
    var historySegments: [GameHistorySegment] { get set }
    var id: UUID { get }
    
    mutating func playerNameChanged(withIndex index: Int, toName name: String)
    mutating func movePlayerAt(_ sourceRowIndex: Int, to destinationRowIndex: Int)
    mutating func addPlayer()
    mutating func randomizePlayers()
    mutating func deletePlayerAt(_ index: Int)
    mutating func editScore(scoreChange: ScoreChange)
    mutating func endRound(_ endRound: EndRound)
    mutating func updateSettings(with gameEndType: GameEndType, endingScore: Int, andNumberOfRounds numberOfRounds: Int)
    mutating func resetGame()
    mutating func editScoreChange(_ newScoreChange: ScoreChange)
    mutating func editEndRound(_ newEndRound: EndRound)
    mutating func deleteHistorySegmentAt(index: Int)
    
    func isEqualTo(game: GameProtocol) -> Bool
    func isEndOfGame() -> Bool
}

struct Game: GameProtocol {
    
    // MARK: - Initialization
    
    init(basicGameWithPlayers players: [PlayerProtocol]) {
        self.gameType = .basic
        self.gameEndType = .none
        self.currentRound = 1
        self.players = players
        self.numberOfRounds = 2
        self.endingScore = 10
    }
    
    init(gameType: GameType,
         gameEndType: GameEndType,
         numberOfRounds: Int = 2,
         currentRound: Int = 1,
         endingScore: Int = 10,
         numberOfPlayers: Int) {
        self.gameType = gameType
        self.gameEndType = gameEndType
        self.numberOfRounds = numberOfRounds
        self.currentRound = currentRound
        self.endingScore = endingScore
        
        var players = [Player]()
        for i in 0..<numberOfPlayers {
            players.append(Player(name: "", position: i))
        }
        self.players = players
    }
    
    
    // MARK: - Properties
    
    var id: UUID = UUID()
    var gameType: GameType
    var gameEndType: GameEndType
    var numberOfRounds: Int
    var currentRound: Int
    var endingScore: Int
    
    var players: [PlayerProtocol]
    var historySegments: [GameHistorySegment] = []
    
    var winningPlayers: [PlayerProtocol] {
        let sortedPlayers = players.sorted { $0.score>$1.score }
        return players.filter { $0.score == (sortedPlayers.first?.score ?? 0) }
    }
    
    
    // MARK: - Mutating Functions
    
    mutating func playerNameChanged(withIndex index: Int, toName name: String) {
        guard players.indices.contains(index) else { return }
        var player = players[index]
        player.name = name
        
        for i in 0..<player.scoreChanges.count {
            player.scoreChanges[i].playerName = name
        }
        
        // This is for changing the names on the score changes
        historySegments.enumerated().forEach { (segmentIndex, segment) in
            if case .scoreChange(var scoreChange, let segmentPlayer) = segment {
                if player.id == segmentPlayer.id {
                    scoreChange.playerName = name
                    
                    let scoreChangeHistorySegment = GameHistorySegment.scoreChange(scoreChange, player)
                    historySegments[segmentIndex] = scoreChangeHistorySegment
                }
            } else if case .endRound(var endRound, let players) = segment {
                endRound.scoreChangeArray.enumerated().forEach { (scoreChangeIndex, scoreChange) in
                    if scoreChange.playerID == player.id {
                        endRound.scoreChangeArray[scoreChangeIndex].playerName = name
                    }
                }
                
                let endRoundHistorySegment = GameHistorySegment.endRound(endRound, players)
                historySegments[segmentIndex] = endRoundHistorySegment
            }
        }
    }
    
    mutating func movePlayerAt(_ sourceRowIndex: Int, to destinationRowIndex: Int) {
        guard players.indices.contains(sourceRowIndex),
              players.indices.contains(destinationRowIndex) else { return }
        
        let playerToMove = players[sourceRowIndex]
        players.remove(at: sourceRowIndex)
        players.insert(playerToMove, at: destinationRowIndex)
        players.setPositions()
    }
    
    mutating func addPlayer() {
        players.append(Player(name: "", position: players.indices.upperBound))
    }
    
    mutating func randomizePlayers() {
        players.shuffle()
        players.setPositions()
    }
    
    mutating func deletePlayerAt(_ index: Int) {
        guard players.indices.contains(index) else {
            return
        }
        
        let player = players[index]
        
        players.remove(at: index)
        players.setPositions()
        
        
        // Cycle backwards through history so deleting one won't affect other indices
        historySegments.enumerated().reversed().forEach { (segmentIndex, segment) in
            
            // Check if history segment is score change
            if case .scoreChange(_, let segmentPlayer) = segment {
                
                // Remove segment from history if it's players
                if player.id == segmentPlayer.id {
                    historySegments.remove(at: segmentIndex)
                }
            } else if case .endRound(var endRound, var players) = segment {
                
                // Remove players and score changes from end round segment
                players.removeAll { $0.id == player.id }
                endRound.scoreChangeArray.removeAll { $0.playerID == player.id }
                
                // Set EndRound segment to values with player removed
                historySegments[segmentIndex] = GameHistorySegment.endRound(endRound, players)
            }
        }
    }
    
    mutating func editScore(scoreChange: ScoreChange) {
        guard let index = players.firstIndex(where: { $0.id == scoreChange.playerID }) else { return }
        
        players[index].scoreChanges.append(scoreChange)
        let historySegment = GameHistorySegment.scoreChange(scoreChange, players[index])
        
        historySegments.append(historySegment)
    }
    
    mutating func endRound(_ endRound: EndRound) {
        
        var playersInThisRound: [PlayerProtocol] = []
        
        endRound.scoreChangeArray.forEach { scoreChange in
            if let index = players.firstIndex(where: { $0.id == scoreChange.playerID }) {
                players[index].scoreChanges.append(scoreChange)
                playersInThisRound.append(players[index])
            } else {
                fatalError("Player not found")
            }
        }
        
        let historySegment = GameHistorySegment.endRound(endRound, playersInThisRound)
        historySegments.append(historySegment)
        
        currentRound += 1
    }
    
    mutating func updateSettings(with gameEndType: GameEndType, endingScore: Int, andNumberOfRounds numberOfRounds: Int) {
        self.gameEndType = gameEndType
        self.numberOfRounds = numberOfRounds
        self.endingScore = endingScore
    }
    
    mutating func deleteHistorySegmentAt(index: Int) {
        guard historySegments.indices.contains(index) else { return }
        
        let historySegmentToRemove = historySegments[index]
        
        // Remove History Segment from game
        historySegments.remove(at: index)
        
        if case .scoreChange(let scoreChange, var player) = historySegmentToRemove {
            // Remove scoreChange from player
            player.scoreChanges.removeAll { $0 == scoreChange }
            
        } else if case .endRound(let endRound, _) = historySegmentToRemove {
            
            // Set New Round Numbers For End Round Segments
            var endRoundCount = 1
            historySegments.enumerated().forEach { (index, segment) in
                if case .endRound(var newEndRound, let endRoundPlayers) = segment {
                    newEndRound.roundNumber = endRoundCount
                    historySegments[index] = GameHistorySegment.endRound(newEndRound, endRoundPlayers)
                    
                    endRoundCount += 1
                }
            }
            
            // Set new current round number
            self.currentRound = endRoundCount
            
            // For each score change that needs to be deleted
            endRound.scoreChangeArray.forEach { endRoundScoreChange in
                
                // If it is tied to player in array and player has score change
                if var player = players.first(where: { $0.id == endRoundScoreChange.playerID }),
                   let indexOfScoreChangeToRemove = player.scoreChanges.firstIndex(of: endRoundScoreChange) {
                    
                    // Delete the score change
                    player.scoreChanges.remove(at: indexOfScoreChangeToRemove)
                }
            }
        }
        
       
    }
    
    mutating func resetGame() {
        for i in 0..<players.count {
            players[i].scoreChanges = []
        }
        
        currentRound = 1
        
        historySegments = []
    }
    
    mutating func editScoreChange(_ newScoreChange: ScoreChange) {
        
        if let playerIndex = players.firstIndex(where: { $0.id == newScoreChange.playerID }),
           let scoreChangeIndex = historySegments.getIndexOfElement(withID: newScoreChange.id),
           case .scoreChange(let scoreChangeOriginal, let player) = historySegments[scoreChangeIndex] {
            
            guard let scoreChangeIndex = players[playerIndex].scoreChanges.firstIndex(of: newScoreChange) else {
                fatalError("Score change not found")
            }
            
            players[playerIndex].scoreChanges[scoreChangeIndex] = (newScoreChange)
            historySegments[scoreChangeIndex] = .scoreChange(newScoreChange, players[playerIndex])
        }
    }
    
    mutating func editEndRound(_ newEndRound: EndRound) {
        
        var playerInEndRoundArray = [PlayerProtocol]()
        
        // Loop through new score changes
        newEndRound.scoreChangeArray.forEach { newScoreChange in
            // find player index for player in new scoreChange
            guard let playerIndex = players.firstIndex(where: { $0.id == newScoreChange.playerID }) else {
                fatalError("Player not in player array")
            }
            
            var player = players[playerIndex]
            
            // Append player to players in this endRound array
            playerInEndRoundArray.append(player)
            
            // Find the index of score change in player
            guard let playerScoreChangeIndex = player.scoreChanges.firstIndex(of: newScoreChange) else {
                fatalError("Score change not in player score change array")
            }
            
            // Set player ScoreChange to new value
            player.scoreChanges[playerScoreChangeIndex] = newScoreChange
        }
        
        // Find the end round history object
        guard let endRoundIndex = historySegments.getIndexOfElement(withID: newEndRound.id) else {
            fatalError("EndRound object not found")
        }
        
        // Set the history object to new changes
        let newGameHistorySegment = GameHistorySegment.endRound(newEndRound, playerInEndRoundArray)
        historySegments[endRoundIndex] = newGameHistorySegment
    }
    
    // MARK: - Non-Mutating Functions
    
    func isEqualTo(game: GameProtocol) -> Bool {
        game.id == self.id
    }
    
    func isEndOfGame() -> Bool {
        switch gameEndType {
        case .none:
            return false
        case .round:
            return currentRound > numberOfRounds
        case .score:
            return players.contains { $0.score >= endingScore }
        }
    }
}

enum GameType: Int, CaseIterable {
    case basic = 0
    case round = 1
}

enum GameEndType: Int, CaseIterable {
    case none = 0
    case round = 1
    case score = 2
}
