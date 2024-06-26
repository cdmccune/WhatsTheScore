//
//  GameTabCoreDataHelperTests.swift
//  Whats The Score Tests
//
//  Created by Curt McCune on 4/5/24.
//

import XCTest
import CoreData
@testable import Whats_The_Score

final class GameTabCoreDataHelperTests: XCTestCase {
    
    // MARK: - StartQuickGame

    func test_GameTabCoreDataHelper_WhenStartQuickGameCalled_ShouldInitializeAGameInViewContext() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        // when
        _ = sut.startQuickGame()
        
        // then
        
        do {
            let games = try coreDataStore.persistentContainer.viewContext.fetch(Game.fetchRequest()) as? [Game]
            XCTAssertEqual(games?.count, 1)
        } catch {
            XCTFail("games couldn't be loaded from view context \(error)")
        }
    }
    
    func test_GameTabCoreDataHelper_WhenStartQuickGameCalled_ShouldSetTwoPlayersInGameWithNamesPlayer1AndPlayer2AndCorrectPositions() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        // when
        _ = sut.startQuickGame()
        
        // then
        
        do {
            let games = try coreDataStore.persistentContainer.viewContext.fetch(Game.fetchRequest())  as? [Game]
            XCTAssertEqual(games?.first?.players.count, 2)
            XCTAssertEqual(games?.first?.players[0].name, "Player 1")
            XCTAssertEqual(games?.first?.players[0].position, 0)
            XCTAssertEqual(games?.first?.players[1].name, "Player 2")
            XCTAssertEqual(games?.first?.players[1].position, 1)
        } catch {
            XCTFail("games couldn't be loaded from view context \(error)")
        }
    }
    
    func test_GameTabCoreDataHelper_WhenStartQuickGameCalled_ShouldSetPlayerIconsToNotEqualIcons() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        // when
        _ = sut.startQuickGame()
        
        // then
        
        do {
            let games = try coreDataStore.persistentContainer.viewContext.fetch(Game.fetchRequest())  as? [Game]
            XCTAssertNotEqual(games?.first?.players[0].icon, games?.first?.players[1].icon)
        } catch {
            XCTFail("games couldn't be loaded from view context \(error)")
        }
    }
    
    func test_GameTabCoreDataHelper_WhenStartQuickGameCalled_ShouldSetGameNameToQuickGame() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        // when
        _ = sut.startQuickGame()
        
        // then
        
        do {
            let games = try coreDataStore.persistentContainer.viewContext.fetch(Game.fetchRequest())  as? [Game]
            XCTAssertEqual(games?.first?.name, "Quick Game")
        } catch {
            XCTFail("games couldn't be loaded from view context \(error)")
        }
    }
    
    func test_GameTabCoreDataHelper_WhenStartQuickGameCalled_ShouldSetGameTypeToBasicAndStatusActive() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        // when
        _ = sut.startQuickGame()
        
        // then
        
        do {
            let games = try coreDataStore.persistentContainer.viewContext.fetch(Game.fetchRequest())  as? [Game]
            XCTAssertEqual(games?.first?.gameType, .basic)
            XCTAssertEqual(games?.first?.gameStatus, .active)
        } catch {
            XCTFail("games couldn't be loaded from view context \(error)")
        }
    }
    
    func test_GameTabCoreDataHelper_WhenStartQuickGameCalled_ShouldCallSaveContextOnCoreDataStore() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        // when
        _ = sut.startQuickGame()
        
        // then
        XCTAssertEqual(coreDataStore.saveContextCalledCount, 1)
    }

    // MARK: - InitializeGame
    
    func test_GameTabCoreDataHelper_WhenInitializeGameCalled_ShouldInitializeGameWithNameGameTypeAndGameEndTypeAndStatusActive() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        let gameType = GameType.allCases.randomElement()!
        let gameEndType = GameEndType.allCases.randomElement()!
        let name = UUID().uuidString
        
        // when
        _ = sut.initializeGame(with: gameType, gameEndType, gameEndQuantity: 0, [], andName: name)
        
        // then
        do {
            let games = try coreDataStore.persistentContainer.viewContext.fetch(Game.fetchRequest())  as? [Game]
            XCTAssertEqual(games?.first?.gameType, gameType)
            XCTAssertEqual(games?.first?.gameEndType, gameEndType)
            XCTAssertEqual(games?.first?.gameStatus, .active)
            XCTAssertEqual(games?.first?.name, name)
        } catch {
            XCTFail("games couldn't be loaded from view context \(error)")
        }
    }
    
    func test_GameTabCoreDataHelper_WhenInitializeGameCalledGameTypeRoundGameEndTypeRound_ShouldSetGameNumberOfRoundsToGameEndQuantity() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        let gameEndQuantity = Int.random(in: 2...10)
        
        // when
        _ = sut.initializeGame(with: GameType.round,
                               GameEndType.round,
                               gameEndQuantity: gameEndQuantity,
                               [],
                               andName: "")
        
        // then
        do {
            let games = try coreDataStore.persistentContainer.viewContext.fetch(Game.fetchRequest())  as? [Game]
            XCTAssertEqual(games?.first?.numberOfRounds, gameEndQuantity)
            
        } catch {
            XCTFail("games couldn't be loaded from view context \(error)")
        }
    }
    
    func test_GameTabCoreDataHelper_WhenInitializeGameCalledGameTypeRoundGameEndTypeScore_ShouldSetGameEndingScoreToGameEndQuantity() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        let gameEndQuantity = Int.random(in: 2...10)
        
        // when
        _ = sut.initializeGame(with: GameType.round,
                               GameEndType.score,
                               gameEndQuantity: gameEndQuantity,
                               [],
                               andName: "")
        
        // then
        do {
            let games = try coreDataStore.persistentContainer.viewContext.fetch(Game.fetchRequest())  as? [Game]
            XCTAssertEqual(games?.first?.endingScore, gameEndQuantity)
            
        } catch {
            XCTFail("games couldn't be loaded from view context \(error)")
        }
    }
    
    func test_GameTabCoreDataHelper_WhenInitializeGameCalled_ShouldCreatePlayersFromPlayerSettings() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        let playerCount = Int.random(in: 2...10)
        let playerSettings = Array(repeating: PlayerSettings.getStub(), count: playerCount)
        
        // when
        _ = sut.initializeGame(with: .round,
                               .score,
                               gameEndQuantity: 0,
                               playerSettings,
                               andName: "")
        
        // then
        do {
            let games = try coreDataStore.persistentContainer.viewContext.fetch(Game.fetchRequest())  as? [Game]
            XCTAssertEqual(games?.first?.players.count, playerCount)
            
        } catch {
            XCTFail("games couldn't be loaded from view context \(error)")
        }
    }
    
    func test_GameTabCoordinator_WhenInitializeGameCalled_ShouldSetPlayerPositionsCorrectly() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        let playerCount = Int.random(in: 2...10)
        let playerSettings = Array(repeating: PlayerSettings.getStub(), count: playerCount)
        
        // when
        _ = sut.initializeGame(with: .round,
                               .score,
                               gameEndQuantity: 0,
                               playerSettings,
                               andName: "")
        
        // then
        do {
            let games = try coreDataStore.persistentContainer.viewContext.fetch(Game.fetchRequest())  as? [Game]
            games?.first?.players.enumerated().forEach({ (index, player) in
                XCTAssertEqual(player.position, index - 1)
            })
            
        } catch {
            XCTFail("games couldn't be loaded from view context \(error)")
        }
    }
    
    func test_GameTabCoordinator_WhenInitializeGameCalled_ShouldSetPlayerIcon() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        let playerIcon = PlayerIcon.allCases.randomElement()!
        
        // when
        _ = sut.initializeGame(with: .round,
                               .score,
                               gameEndQuantity: 0,
                               [PlayerSettings.getStub(icon: playerIcon)],
                               andName: "")
        
        // then
        do {
            let games = try coreDataStore.persistentContainer.viewContext.fetch(Game.fetchRequest())  as? [Game]
            XCTAssertEqual(games?.first?.players.first?.icon, playerIcon)
            
        } catch {
            XCTFail("games couldn't be loaded from view context \(error)")
        }
    }
    
    func test_GameTabCoreDataHelper_WhenInitializeGameCalled_ShouldCallSaveContextOnCoreDataStore() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        // when
        _ = sut.initializeGame(with: .basic, .none, gameEndQuantity: 0, [], andName: "")
        
        // then
        XCTAssertEqual(coreDataStore.saveContextCalledCount, 1)
    }
    
    
    // MARK: - EndGame
    
    func test_GameTabCoreDataHelper_WhenEndGameCalled_ShouldSetGameGameStatusToCompleted() {
        // given
        let sut = GameTabCoreDataHelper(coreDataStore: CoreDataStoreMock())
        let game = GameMock(gameStatus: .active)
        
        // when
        sut.endGame(game)
        
        // then
        XCTAssertEqual(game.gameStatus, .completed)
    }
    
    func test_GameTabCoreDataHelper_WhenEndGameCalled_ShouldCallSaveContextOnCoreDataStore() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        // when
        sut.endGame(GameMock())
        
        // then
        XCTAssertEqual(coreDataStore.saveContextCalledCount, 1)
    }
    
    
    // MARK: - MakeGameActive
    
    func test_GameTabCoreDataHelper_WhenMakeGameActiveCalled_ShouldSetGameGameStatusToActive() {
        // given
        let sut = GameTabCoreDataHelper(coreDataStore: CoreDataStoreMock())
        let game = GameMock(gameStatus: .completed)
        
        // when
        sut.makeGameActive(game)
        
        // then
        XCTAssertEqual(game.gameStatus, .active)
    }
    
    func test_GameTabCoreDataHelper_WhenMakeGameActiveCalled_ShouldCallSaveContextOnCoreDataStore() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        // when
        sut.makeGameActive(GameMock())
        
        // then
        XCTAssertEqual(coreDataStore.saveContextCalledCount, 1)
    }
    
    
    // MARK: - DeleteGame
    
    func test_GameTabCoreDataHelper_WhenDeleteGameCalled_ShouldCallDeleteObjectOnCoreDataStoreWithGame() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        let game = Game()
        
        // when
        sut.deleteGame(game)
        
        // then
        XCTAssertIdentical(game, coreDataStore.deleteObjectObject)
    }
    
    func test_GameTabCoreDataHelper_WhenDeleteGameCalled_ShouldCallSaveContextOnCoreDataStore() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        // when
        sut.deleteGame(Game())
        
        // then
        XCTAssertEqual(coreDataStore.saveContextCalledCount, 1)
    }


    // MARK: - MakeCopyOfGame
    
    func test_GameTabCoreDataHelper_WhenMakeCopyOfGameCalled_ShouldReturnGameNotIdenticalToGameSent() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        let game = GameMock()
        
        // when
        let copy = sut.makeCopyOfGame(game)
        
        // then
        XCTAssertNotIdentical(copy, game)
    }
    

    func test_GameTabCoreDataHelper_WhenMakeCopyOfGameCalled_ShouldReturnGameWithSamePropertiesAsGameSent() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        let game = GameMock()
        game.name = UUID().uuidString
        game.gameType = GameType.allCases.randomElement()!
        game.gameEndType = GameEndType.allCases.randomElement()!
        game.numberOfRounds = Int.random(in: 2...10)
        game.endingScore = Int.random(in: 2...10)
        game.players = [PlayerMock(), PlayerMock()]
        
        // when
        let copy = sut.makeCopyOfGame(game)
        
        // then
        XCTAssertEqual(copy.name, game.name)
        XCTAssertEqual(copy.gameType, game.gameType)
        XCTAssertEqual(copy.gameEndType, game.gameEndType)
        XCTAssertEqual(copy.numberOfRounds, game.numberOfRounds)
        XCTAssertEqual(copy.endingScore, game.endingScore)
        
        copy.players.enumerated().forEach { (index, player) in
            XCTAssertEqual(player.name, game.players[index].name)
            XCTAssertEqual(player.icon, game.players[index].icon)
        }
    }
    
    func test_GameTabCoreDataHelper_WhenMakeCopyOfGameCalled_ShouldAddNewGameToContext() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        // when
        _ = sut.makeCopyOfGame(GameMock())
        
        // then
        
        do {
            let games = try coreDataStore.persistentContainer.viewContext.fetch(Game.fetchRequest()) as? [Game]
            XCTAssertEqual(games?.count, 1)
        } catch {
            XCTFail("games couldn't be loaded from view context \(error)")
        }
    }

    func test_GameTabCoreDataHelper_WhenMakeCopyOfGameCalled_ShouldCallSaveContextOnCoreDataStore() {
        // given
        let coreDataStore = CoreDataStoreMock()
        let sut = GameTabCoreDataHelper(coreDataStore: coreDataStore)
        
        // when
        _ = sut.makeCopyOfGame(GameMock())
        
        // then
        XCTAssertEqual(coreDataStore.saveContextCalledCount, 1)
    }
}
