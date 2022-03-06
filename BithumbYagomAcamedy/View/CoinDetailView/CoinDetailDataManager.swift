//
//  CoinDetailDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/03.
//

import Foundation

protocol CoinDetailDataManagerDelegate: AnyObject {
    func coinDetailDataManager(didChange coin: DetailViewCoin?)
}

final class CoinDetailDataManager {
        
    // MARK: - Property
    
    weak var delegate: CoinDetailDataManagerDelegate?
    private var tickerWebSocketService: WebSocketService
    private var transactionWebSocketService: WebSocketService
    private var detailCoin: DetailViewCoin? {
        didSet {
            delegate?.coinDetailDataManager(didChange: detailCoin)
        }
    }
    
    // MARK: - Init
    
    init(
        tickerWebSocketService: WebSocketService = WebSocketService(),
        transactionWebSocketService: WebSocketService = WebSocketService()
    ) {
        self.tickerWebSocketService = tickerWebSocketService
        self.transactionWebSocketService = transactionWebSocketService
    }
    
    // MARK: - Deinit
    
    deinit {
        tickerWebSocketService.close()
        transactionWebSocketService.close()
    }
}

// MARK: - Data Processing

extension CoinDetailDataManager {
    func configureDetailCoin(coin: Coin?) {
        guard let coin = coin else {
            return
        }
        
        detailCoin = DetailViewCoin(
            name: coin.symbolName,
            price: coin.currentPrice,
            changePrice: coin.changePrice,
            changeRate: coin.changeRate
        )
    }
}

// MARK: - Ticker WebSocket Network

extension CoinDetailDataManager {
    func fetchTickerWebSocket() {
        guard let symbol = detailCoin?.symbol else {
            return
        }
        
        let api = TickerWebSocket(symbol: symbol)
        
        tickerWebSocketService.open(webSocketAPI: api) { [weak self] result in
            guard let message = result.value else {
                print(result.error?.localizedDescription as Any)
                return
            }
            
            switch message {
            case .string(let response):
                let ticker = try? self?.parseWebSocketTicker(to: response)
                
                guard let changePrice = ticker?.webSocketTickerData.changePrice,
                      let changeRate = ticker?.webSocketTickerData.changeRate
                else {
                    return
                }
                
                self?.detailCoin?.setChangePrice(Double(changePrice))
                self?.detailCoin?.setChangeRate(Double(changeRate))
            default:
                break
            }
        }
    }
    
    private func parseWebSocketTicker(
        to string: String
    ) throws -> WebSocketTickerValueObject {
        do {
            let webSocketTickerValueObjcet = try JSONParser().decode(
                string: string,
                type: WebSocketTickerValueObject.self
            )
            
            return webSocketTickerValueObjcet
        } catch {
            print(error.localizedDescription)
            
            throw error
        }
    }
}

// MARK: - Transaction WebSocket Network

extension CoinDetailDataManager {
    func fetchTransactionWebSocket() {
        guard let symbol = detailCoin?.symbol else {
            return
        }
        
        let api = TransactionWebSocket(symbol: symbol)
        
        transactionWebSocketService.open(webSocketAPI: api) { [weak self] result in
            guard let message = result.value else {
                print(result.error?.localizedDescription as Any)
                return
            }
            
            switch message {
            case .string(let response):
                let transaction = try? self?.parseWebSocketTranscation(to: response)
                
                guard let transactionList = transaction?.webSocketTransactionData.list,
                      let latestTransaction = transactionList.reversed().first
                else {
                    return
                }
                
                self?.detailCoin?.setPrice(Double(latestTransaction.price))
            default:
                break
            }
        }
    }
    
    private func parseWebSocketTranscation(
        to string: String
    ) throws -> WebSocketTransactionValueObject {
        do {
            let webSocketTransactionValueObject = try JSONParser().decode(
                string: string,
                type: WebSocketTransactionValueObject.self
            )
            
            return webSocketTransactionValueObject
        } catch {
            print(error.localizedDescription)
            
            throw error
        }
    }
}
