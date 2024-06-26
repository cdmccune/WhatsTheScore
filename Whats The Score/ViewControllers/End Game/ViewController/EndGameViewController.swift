//
//  EndGameViewController.swift
//  Whats The Score
//
//  Created by Curt McCune on 3/1/24.
//

import UIKit

class EndGameViewController: UIViewController, Storyboarded {
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var keepPlayingButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    
    // MARK: - Properties
    
    private lazy var tableViewDelegate = EndGamePlayerTableViewDelegate(viewModel: viewModel)
    private lazy var collectionViewDelegate = EndGamePlayerCollectionViewDelegate(viewModel: viewModel)
    lazy var screenWidth: CGFloat = view.frame.width
    var viewModel: EndGameViewModelProtocol!
    weak var coordinator: EndGameCoordinatorProtocol?
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setDelegates()
        registerNibs()
        setupViews()
    }
    
    
    // MARK: - Private Functions
    
    private func setDelegates() {
        tableView.delegate = tableViewDelegate
        tableView.dataSource = tableViewDelegate
        collectionView.delegate = collectionViewDelegate
        collectionView.dataSource = collectionViewDelegate
    }
    
    private func registerNibs() {
        tableView.register(UINib(nibName: "EndGamePlayerTableViewCell", bundle: nil), forCellReuseIdentifier: "EndGamePlayerTableViewCell")
        collectionView.register(UINib(nibName: "EndGamePlayerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EndGamePlayerCollectionViewCell")
    }
    
    private func setupViews() {

        winnerLabel.text = viewModel.game.winningPlayers.count == 1 ? "Winner" : "Winners"
        
        let reportAttributedString = NSMutableAttributedString(string: "Report")
        reportAttributedString.addStrokeAttribute(strokeColor: .black, strokeWidth: 4.0)
        reportAttributedString.addTextColorAttribute(textColor: .white)
        titleLabel.attributedText = reportAttributedString
        
        let numberOfWinningPlayersCGFloat = CGFloat(viewModel.game.winningPlayers.count)
        let widthOfCollectionViewContent = (160 * numberOfWinningPlayersCGFloat) + (25 * (numberOfWinningPlayersCGFloat - 1))
        
        if widthOfCollectionViewContent > screenWidth {
            self.collectionViewWidth.constant = screenWidth
        } else {
            self.collectionViewWidth.constant = widthOfCollectionViewContent
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func playAgainButtonTapped(_ sender: Any) {
        coordinator?.playGameAgain(viewModel.game)
    }
    
    
    @IBAction func keepPlayingGameButtonTapped(_ sender: Any) {
        coordinator?.reopenNonActiveGame(viewModel.game)
    }
}
