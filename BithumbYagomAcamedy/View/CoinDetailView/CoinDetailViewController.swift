//
//  CoinDetailViewController.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/02.
//

import UIKit

final class CoinDetailViewController: UIViewController {

    // MARK: - View
   
    @IBOutlet private weak var coinDetailPriceView: CoinDetailPriceView!
    private var pageViewController : CoinDetailPageViewController?
    private lazy var titleButton = makeTitleButton(coin: coin)
    @IBOutlet weak var menuButtonStackView: CoinDetailMenuStackView!
    
    // MARK: - Property
    
    var coin: Coin?
    private let coinDetailDataManager = CoinDetailDataManager()
    private var currentIndex : Int = 0 {
        didSet{
            menuButtonStackView.moveUnderLine(index: currentIndex)
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTitle()
        configureNavigationBackButton()
        configureDataManager()
    }
    
    // MARK: - Override Method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CoinDetailPageViewController" {
            guard let pageViewController = segue.destination as? CoinDetailPageViewController else {
                return
            }
            
            self.pageViewController = pageViewController
            self.pageViewController?.completeHandler = { [weak self] index in
                self?.currentIndex = index
            }
        }
    }
    
    // MARK: - IBAction
    
    
    @IBAction private func chartMenuButtonTap(_ sender: Any) {
        pageViewController?.setViewcontrollersFromIndex(index: 0)
    }
    
    @IBAction private func orderbookMenuButtonTap(_ sender: Any) {
        pageViewController?.setViewcontrollersFromIndex(index: 1)
    }
    
    @IBAction private func transactionMenuButtonTap(_ sender: Any) {
        pageViewController?.setViewcontrollersFromIndex(index: 2)
    }
}

// MARK: - Navigation Bar

extension CoinDetailViewController {
    private func makeTitleButton(coin: Coin?) -> UIButton {
        let titleButton = CoinDetailTitleButton()
        titleButton.configureAttributedTitle(coin: coin)
        
        return titleButton
    }
    
    private func configureTitle() {
        navigationItem.titleView = titleButton
    }
    
    private func configureNavigationBackButton() {
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.topItem?.title = String()
    }
}

// MARK: - Coin Detail DataManager

extension CoinDetailViewController {
    private func configureDataManager() {
        coinDetailDataManager.delegate = self
        coinDetailDataManager.configureDetailCoin(coin: coin)
        coinDetailDataManager.fetchTickerWebSocket()
        coinDetailDataManager.fetchTransactionWebSocket()
    }
}

extension CoinDetailViewController: CoinDetailDataManagerDelegate {
    func coinDetailDataManager(didChange coin: CoinDetailDataManager.DetailViewCoin?) {
        guard let coin = coin else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.coinDetailPriceView.update(coin)
        }
    }
}


