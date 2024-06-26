//
//  EndGameViewControllerTests.swift
//  Whats The Score Tests
//
//  Created by Curt McCune on 3/1/24.
//

import XCTest
@testable import Whats_The_Score

final class EndGameViewControllerTests: XCTestCase {

    // MARK: - Setup
    
    var viewController: EndGameViewController!
    var views: [UIView]?

    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "EndGameViewController") as? EndGameViewController else {
            fatalError("EndGameViewController wasn't found")
        }
        self.viewController = viewController
    }
    
    override func tearDown() {
        viewController = nil
    }
    
    
    // MARK: - Initialization
    
    func test_EndGameViewController_WhenViewLoaded_ShouldHaveNonNilOutlets() {
        // given
        let sut = viewController!
        
        // when
        sut.loadView()
        
        // then
        XCTAssertNotNil(sut.tableView)
    }
    
    
    // MARK: - ViewDidLoad

    func test_EndGameViewController_WhenViewDidLoadCalledAndSingleWinner_ShouldDisplayWinnerInLabel() {
        // given
        let sut = viewController!
        let gameMock = GameMock()
        gameMock.winningPlayers = [PlayerMock()]
        let viewModelMock = EndGameViewModelMock()
        viewModelMock.game = gameMock
        sut.viewModel = viewModelMock
        sut.loadView()
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertEqual(sut.winnerLabel.text, "Winner")
    }
    
    func test_EndGameViewController_WhenViewDidLoadCalledAndMultipleWinners_ShouldDisplayWinnersInLabel() {
        // given
        let sut = viewController!
        let gameMock = GameMock()
        gameMock.winningPlayers = [PlayerMock(), PlayerMock()]
        let viewModelMock = EndGameViewModelMock()
        viewModelMock.game = gameMock
        sut.viewModel = viewModelMock
        sut.loadView()
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertEqual(sut.winnerLabel.text, "Winners")
    }
    
    func test_EndGameViewController_WhenViewDidLoadCalled_ShouldSetTableViewDelegateDatasourceToEndGamePlayerTableViewDelegate() {
        // given
        let sut = viewController!
        sut.loadView()
        sut.viewModel = EndGameViewModelMock()
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertTrue(sut.tableView.delegate is EndGamePlayerTableViewDelegate)
        XCTAssertTrue(sut.tableView.dataSource is EndGamePlayerTableViewDelegate)
    }
    
    func test_EndGameViewController_WhenViewDidLoadCalled_ShouldSetTableViewDelegateViewModelAsViewModel() {
        // given
        let sut = viewController!
        let viewModelMock = EndGameViewModelMock()
        sut.viewModel = viewModelMock
        sut.loadView()
        
        // when
        sut.viewDidLoad()
        
        // then
        let tableViewDelegate = sut.tableView.delegate as? EndGamePlayerTableViewDelegate
        XCTAssertTrue((tableViewDelegate?.viewModel as? EndGameViewModelMock) === viewModelMock)
    }
    
    func test_EndGameViewController_WhenViewDidLoadCalled_ShouldSetCollectionViewDelegateDatasourceToEndGamePlayerCollectionViewDelegate() {
        // given
        let sut = viewController!
        sut.loadView()
        sut.viewModel = EndGameViewModelMock()
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertTrue(sut.collectionView.delegate is EndGamePlayerCollectionViewDelegate)
        XCTAssertTrue(sut.collectionView.dataSource is EndGamePlayerCollectionViewDelegate)
    }
    
    func test_EndGameViewController_WhenViewDidLoadCalled_ShouldSetCollectionViewDelegateViewModelAsViewModel() {
        // given
        let sut = viewController!
        let viewModelMock = EndGameViewModelMock()
        sut.viewModel = viewModelMock
        sut.loadView()
        
        // when
        sut.viewDidLoad()
        
        // then
        let collectionViewDelegate = sut.collectionView.delegate as? EndGamePlayerCollectionViewDelegate
        XCTAssertTrue((collectionViewDelegate?.viewModel as? EndGameViewModelMock) === viewModelMock)
    }
    
    func test_EndGameViewController_WhenViewDidLoadCalled_ShouldRegisterEndGamePlayerTableViewCellInTableView() {
        // given
        let sut = viewController!
        let viewModelMock = EndGameViewModelMock()
        sut.viewModel = viewModelMock
        
        
        // when
        sut.loadView()
        sut.viewDidLoad()
        
        // then
        let cell = sut.tableView.dequeueReusableCell(withIdentifier: "EndGamePlayerTableViewCell")
        
        XCTAssertTrue(cell is EndGamePlayerTableViewCell)
    }
    
    func test_EndGameViewController_WhenViewDidLoadCalled_ShouldRegisterEndGamePlayerCollectionViewCellInCollectionView() {
        // given
        let sut = viewController!
        let viewModelMock = EndGameViewModelMock()
        sut.viewModel = viewModelMock
        
        
        // when
        sut.loadView()
        sut.viewDidLoad()
        
        // then
        let cell = sut.collectionView.dequeueReusableCell(withReuseIdentifier: "EndGamePlayerCollectionViewCell", for: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(cell is EndGamePlayerCollectionViewCell)
    }
    
    func test_EndGameViewController_WhenViewDidLoadCalled_ShouldSetAttributesForStrokeAndForegroundColorOnTitleLabel() {
        // given
        let sut = viewController!
        viewController.viewModel = EndGameViewModelMock()
        sut.loadView()
        
        // when
        sut.viewDidLoad()
        
        // then
        let attributes = sut.titleLabel.attributedText?.attributes(at: 0, effectiveRange: nil)
        XCTAssertEqual(sut.titleLabel.text, "Report")
        XCTAssertEqual(attributes?[.foregroundColor] as? UIColor, .white)
        XCTAssertEqual(attributes?[.strokeWidth] as? CGFloat, -4.0)
        XCTAssertEqual(attributes?[.strokeColor] as? UIColor, .black)
    }
    
    func test_EndGameViewController_WhenViewDidLoadCalledWinningPlayersCellWidthLessThanScreenWidth_ShouldSetCollectionViewWidthEqualTo128XCountPlus25XCountMinus1() {
        // given
        let sut = viewController!
        
        let context = CoreDataStore(.inMemory).persistentContainer.viewContext
        let numberOfPlayers = Int.random(in: 1...10)
        let players = Array(repeating: Player(context: context), count: numberOfPlayers)
        
        let numberOfPlayersCGFloat = CGFloat(numberOfPlayers)
        let expectedCollectionViewWidth: CGFloat = (160 * numberOfPlayersCGFloat) + (25 * (numberOfPlayersCGFloat - 1))
        
        let screenWidth: CGFloat = expectedCollectionViewWidth + 1
        sut.screenWidth = screenWidth
        
        let viewModel = EndGameViewModelMock()
        
        let game = GameMock()
        game.winningPlayers = players
        viewModel.game = game
        sut.viewModel = viewModel
        
        // when
        sut.loadView()
        sut.viewDidLoad()
        
        // then
        XCTAssertEqual(sut.collectionViewWidth.constant, expectedCollectionViewWidth)
    }
    
    func test_EndGameViewController_WhenViewDidLoadCalledWinningPlayersCellWidthMoreThanScreenWidth_ShouldSetCollectionViewWidthEqualToScreenWidth() {
        // given
        let sut = viewController!
        
        let context = CoreDataStore(.inMemory).persistentContainer.viewContext
        let players = Array(repeating: Player(context: context), count: 15)
        
        let screenWidth: CGFloat = CGFloat.random(in: 1...999)
        sut.screenWidth = screenWidth
        
        let viewModel = EndGameViewModelMock()
        let game = GameMock()
        game.winningPlayers = players
        viewModel.game = game
        sut.viewModel = viewModel
        
        // when
        sut.loadView()
        sut.viewDidLoad()
        
        // then
        XCTAssertEqual(sut.collectionViewWidth.constant, screenWidth)
    }
    
    
    // MARK: - playAgainButtonTapped
    
    func test_EndGameViewController_WhenPlayAgainButtonTapped_ShouldCallCoordinatorPlayGameAgainWithGame() {
        // given
        let sut = viewController!
        let coordinator = EndGameCoordinatorProtocolMock()
        sut.coordinator = coordinator
        
        let game = GameMock()
        sut.viewModel = EndGameViewModel(game: game)
        
        // when
        sut.playAgainButtonTapped(0)
        
        // then
        XCTAssertEqual(coordinator.playGameAgainCalledCount, 1)
        XCTAssertIdentical(coordinator.playGameAgainGame, game)
    }
    
    // MARK: - keepPlayingButtonTapped
    
    func test_EndGameViewController_WhenKeepPlayingButtonTapped_ShouldCallCoordinatorGoToScoreboardWithGame() {
        // given
        let sut = viewController!
        
        let coordinator = EndGameCoordinatorProtocolMock()
        sut.coordinator = coordinator
        
        let game = GameMock()
        sut.viewModel = EndGameViewModel(game: game)
        
        // when
        sut.keepPlayingGameButtonTapped(0)
        
        // then
        XCTAssertEqual(coordinator.reopenCompletedGameCalledCount, 1)
        XCTAssertTrue(coordinator.reopenCompletedGameGame?.isEqualTo(game: game) ?? false)
    }
}
