//
//  CoinDetailPageViewController.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/02.
//

import UIKit

final class CoinDetailPageViewController: UIPageViewController {

    // MARK: - Property
    
    var coin: Coin?
    
    private lazy var viewsList = configureViewList()
    var completeHandler : ((Int) -> Void)?
    var currentIndex : Int {
        guard let viewController = viewControllers?.first else {
            return Int.zero
        }
        
        return viewsList.firstIndex(of: viewController) ?? Int.zero
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureFirstViewController()
    }
    
    // MARK: - configure
    
    private func configure() {
        dataSource = self
        delegate = self
    }
    
    func configureSubViewControllerCompletion(coin: Coin?) {
        guard let coin = coin else {
            return
        }
        
        var pageViewControllerables = viewsList.compactMap {
            $0 as? PageViewControllerable
        }
        
        for index in pageViewControllerables.indices {
            pageViewControllerables[index].completion = {
                pageViewControllerables[index].configureDataManager(coin: coin)
            }
        }
    }
    
    private func configureFirstViewController() {
        guard let firstViewController = viewsList.first else {
            return
        }
        
        setViewControllers(
            [firstViewController],
            direction: .forward,
            animated: true
        )
    }
    
    private func configureViewList() -> [UIViewController] {
        let instantiater = ViewControllerInstantiater()
        let chartViewController = instantiater.instantiate(CoinChartViewInstantiateInformation())
        let orderbookViewController = instantiater.instantiate(CoinOrderbookViewInstantiateInformation())
        let transactionViewController = instantiater.instantiate(CoinTransactionViewInstantiateInformation())
        
        return [chartViewController, orderbookViewController, transactionViewController]
    }
    
    func setViewcontrollersFromIndex(index : Int) {
        guard index >= Int.zero && index < viewsList.count else {
            return
        }
        
        var derection: NavigationDirection = .forward
        
        if index < currentIndex {
            derection = .reverse
        }
        
        setViewControllers(
            [viewsList[index]],
            direction: derection,
            animated: true
        )
        
        completeHandler?(currentIndex)
    }
}

// MARK: - UIPageViewController Delegate

extension CoinDetailPageViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed {
            completeHandler?(currentIndex)
        }
    }
}

// MARK: - UIPageViewController DataSource

extension CoinDetailPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = viewsList.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = index - 1
        
        if previousIndex < 0 {
            return nil
        }
        
        return viewsList[safe: previousIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = viewsList.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = index + 1
        
        if nextIndex == viewsList.count {
            return nil
        }
                
        return viewsList[safe: nextIndex]
    }
}
