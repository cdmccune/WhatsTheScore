//
//  HomeTabCoordinator.swift
//  Whats The Score
//
//  Created by Curt McCune on 3/20/24.
//

import Foundation
import UIKit

class HomeTabCoordinator: Coordinator, EndGameCoordinatorProtocol {
    
    // MARK: - Init
    
    required init(navigationController: RootNavigationController, coreDataStore: CoreDataStoreProtocol = CoreDataStore(.inMemory)) {
        self.navigationController = navigationController
        self.coreDataStore = coreDataStore
    }
    
    
    // MARK: - Properties
    
    var activeGame: GameProtocol?
    var activeGameError: CoreDataStoreError?
    var childCoordinators: [Coordinator] = []
    var navigationController: RootNavigationController
    var coreDataStore: CoreDataStoreProtocol
    
    lazy var coreDataHelper: HomeTabCoordinatorCoreDataHelperProtocol = HomeTabCoordinatorCoreDataHelper(coreDataStore: coreDataStore)
    lazy var dispatchQueue: DispatchQueueProtocol? = DispatchQueue.main
    
    weak var coordinator: MainCoordinator?
    
    
    // MARK: - Functions
    
    func start() {
        let homeVC = HomeViewController.instantiate()
        homeVC.coordinator = self
        homeVC.activeGame = activeGame
        
        if let activeGameError { showError(activeGameError) }
        
        navigationController.viewControllers = [homeVC]
    }
    
    func setupNewGame() {
        pauseCurrentGame {
            self.coordinator?.setupNewGame()
        }
    }
    
    func setupQuickGame() {
        pauseCurrentGame {
            self.coordinator?.setupQuickGame()
        }
    }
    
    func playActiveGame() {
        coordinator?.playActiveGame()
    }
    
    func showMyGames() {
        let myGamesVC = MyGamesViewController.instantiate()
        
        let viewModel = MyGamesViewModel()
        
        do {
            let games = try coreDataHelper.getAllGames()
            viewModel.games = games
        } catch let error as CoreDataStoreError {
            showError(error)
        } catch {
            fatalError("Unhandled error \(error.localizedDescription)")
        }
        
        viewModel.coordinator = self
        myGamesVC.viewModel = viewModel
        
        navigationController.pushViewController(myGamesVC, animated: true)
    }
    
    
    func pauseCurrentGame(andOpenGame newGame: GameProtocol? = nil, completion: @escaping () -> Void = {}) {
        
        if let activeGame {
            let alertController = UIAlertController(title: "Pause Game", message: "Do you want to pause your current game: \(activeGame.name)?", preferredStyle: .alert)
            
            let noAction = TestableUIAlertAction.createWith(title: "No", style: .cancel)
            let yesAction = TestableUIAlertAction.createWith(title: "Yes", style: .destructive) { _ in
                self.coreDataHelper.pauseGame(game: activeGame)
                if let newGame {
                    self.coreDataHelper.makeGameActive(game: newGame)
                }
                self.activeGame = newGame
                self.start()
                
                completion()
            }

            alertController.addAction(noAction)
            alertController.addAction(yesAction)

            navigationController.topViewController?.present(alertController, animated: true)
        } else {
            if let newGame {
                self.coreDataHelper.makeGameActive(game: newGame)
            }
            self.activeGame = newGame
            self.start()
            completion()
        }
    }
    
    func showError(_ error: CoreDataStoreError) {
        dispatchQueue?.asyncAfterWrapper(delay: 0.25, work: {
            let alertController = UIAlertController(title: "Error", message: error.getDescription(), preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(OKAction)
            
            self.navigationController.topViewController?.present(alertController, animated: true)
        })
    }
    
    func reopenNonActiveGame(_ game: GameProtocol) {
        pauseCurrentGame(andOpenGame: game) {
            self.coordinator?.homeTabGameMadeActive(game)
        }
    }
    
    func playGameAgain(_ game: GameProtocol) {
        pauseCurrentGame {
            self.coordinator?.playGameAgain(game)
        }
    }
    
    func showGameReportFor(game: GameProtocol) {
        let endGameVC = EndGameViewController.instantiate()
        endGameVC.coordinator = self
        endGameVC.viewModel = EndGameViewModel(game: game)
        navigationController.pushViewController(endGameVC, animated: true)
    }
    
    func deleteActiveGame() {
        if let activeGame {
            coreDataHelper.deleteGame(activeGame)
        }
        self.activeGame = nil
        
        if let homeViewController = navigationController.viewControllers.first as? HomeViewController {
            homeViewController.activeGame = nil
            homeViewController.viewDidLoad()
        }
        
        coordinator?.homeTabActiveGameDeleted()
    }
    
    func deleteNonActiveGame(_ game: GameProtocol) {
        coreDataHelper.deleteGame(game)
    }
}
