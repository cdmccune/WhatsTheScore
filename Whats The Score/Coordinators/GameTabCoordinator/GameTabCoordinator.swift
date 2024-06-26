//
//  GameTabCoordinator.swift
//  Whats The Score
//
//  Created by Curt McCune on 3/20/24.
//

import Foundation
import StoreKit

class GameTabCoordinator: Coordinator {
    
    required init(navigationController: RootNavigationController, coreDataStore: CoreDataStoreProtocol  = CoreDataStore(.inMemory)) {
        self.coreDataStore = coreDataStore
        self.navigationController = navigationController
    }
    
    lazy var childCoordinators: [Coordinator] = [
        GameSetupCoordinator(navigationController: navigationController, parentCoordinator: self),
        ScoreboardCoordinator(navigationController: navigationController, parentCoordinator: self, coreDataStore: coreDataStore)
    ]
    
    weak var coordinator: MainCoordinator?
    var activeGame: GameProtocol?
    var coreDataStore: CoreDataStoreProtocol
    var navigationController: RootNavigationController
    lazy var coreDataHelper: GameTabCoreDataHelperProtocol = GameTabCoreDataHelper(coreDataStore: coreDataStore)
    
    
    func start() {
        if let activeGame {
            let scoreboardCoordinator = childCoordinators.first { $0 is ScoreboardCoordinator} as? ScoreboardCoordinator
            scoreboardCoordinator?.game = activeGame
            scoreboardCoordinator?.start()
            
        } else {
            childCoordinators.first { $0 is GameSetupCoordinator }?.start()
        }
        
    }
    
    func startQuickGame() {
        let game = coreDataHelper.startQuickGame()
        self.activeGame = game
        coordinator?.gameTabGameMadeActive(game)
        startScoreboard(with: game)
    }
    
    func gameSetupComplete(withGameType gameType: GameType, gameEndType: GameEndType, gameEndQuantity: Int, players: [PlayerSettings], andName name: String) {
        
        _ = childCoordinators.first { $0 is ScoreboardCoordinator } as? ScoreboardCoordinator
        
        let game = coreDataHelper.initializeGame(with: gameType, gameEndType, gameEndQuantity: gameEndQuantity, players, andName: name)
        self.activeGame = game
        
        coordinator?.gameTabGameMadeActive(game)
        startScoreboard(with: game)
    }
    
    func startScoreboard(with game: GameProtocol) {
        let scoreboardCoordinator = childCoordinators.first { $0 is ScoreboardCoordinator } as? ScoreboardCoordinator
        
        scoreboardCoordinator?.game = game
        scoreboardCoordinator?.start()
    }
    
    func showEndGameScreen(forGame game: GameProtocol) {
        let endGameVC = EndGameViewController.instantiate()
        coreDataHelper.endGame(game)
        coordinator?.gameTabActiveGameCompleted()
        
        endGameVC.viewModel = EndGameViewModel(game: game)
        endGameVC.coordinator = self
        
        navigationController.viewControllers = [endGameVC]
        
        // Prompt for rating after presenting the end game screen
        presentRatingRequest()
    }
    
    private func presentRatingRequest() {
        // Ensure rating prompt appears after a slight delay to not interrupt the transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    func deleteGame() {
        guard let activeGame else { return }
        coreDataHelper.deleteGame(activeGame)
        
        coordinator?.gameTabActiveGameCompleted()
        
        self.activeGame = nil
        self.start()
    }
    
    
    // MARK: - EndGameCoordinatorProtocol
    
    func playGameAgain(_ game: GameProtocol) {
        let newGame = coreDataHelper.makeCopyOfGame(game)
        activeGame = newGame
        coordinator?.gameTabGameMadeActive(newGame)
        startScoreboard(with: newGame)
    }
}

extension GameTabCoordinator: EndGameCoordinatorProtocol {
    func reopenNonActiveGame(_ game: GameProtocol) {
        coreDataHelper.makeGameActive(game)
        coordinator?.gameTabGameMadeActive(game)
        
        let scoreboardCoordinator = childCoordinators.first { $0 is ScoreboardCoordinator } as? ScoreboardCoordinator
        
        scoreboardCoordinator?.game = game
        scoreboardCoordinator?.start()
    }
}
