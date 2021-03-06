//
//  CoinOrderbokDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/04.
//

import Foundation

protocol CoinOrderbookDataManagerDelegate: AnyObject {
    func coinOrderbookDataManager(didChange askOrderbooks: [Orderbook], and bidOrderbooks: [Orderbook])
    func coinOrderbookDataManager(didChangeAskMinimumPrice orderbook: Orderbook)
    func coinOrderbookDataManager(didChangeBidMaximumPrice orderbook: Orderbook)
    func coinOrderbookDataManager(didCalculate totalQuantity: String, type: OrderbookType)
    func coinOrderbookDataManagerDidFetchFail()
}

final class CoinOrderbookDataManager {
    
    // MARK: - Property
    
    weak var delegate: CoinOrderbookDataManagerDelegate?
    private let symbol: String
    private let httpNetworkService: HTTPNetworkService
    private var webSocketService: WebSocketService
    private var askOrderbooks: [Orderbook] = [] {
        didSet {
            delegate?.coinOrderbookDataManager(didChange: askOrderbooks, and: bidOrderbooks)
            calculateTotalOrderQuantity(orderbooks: askOrderbooks, type: .ask)
            
            if let minimumPriceAskOrderbook = askOrderbooks.last {
                delegate?.coinOrderbookDataManager(didChangeAskMinimumPrice: minimumPriceAskOrderbook)
            }
        }
    }
    private var bidOrderbooks: [Orderbook] = [] {
        didSet {
            delegate?.coinOrderbookDataManager(didChange: askOrderbooks, and: bidOrderbooks)
            calculateTotalOrderQuantity(orderbooks: bidOrderbooks, type: .bid)
            
            if let maximumPriceAskOrderbook = bidOrderbooks.first {
                delegate?.coinOrderbookDataManager(didChangeBidMaximumPrice: maximumPriceAskOrderbook)
            }
        }
    }
    
    // MARK: - Init
    
    init(
        symbol: String,
        httpNetworkService: HTTPNetworkService = HTTPNetworkService(),
        webSocketService: WebSocketService = WebSocketService()
    ) {
        self.symbol = symbol
        self.httpNetworkService = httpNetworkService
        self.webSocketService = webSocketService
    }
    
    deinit {
        webSocketService.close()
    }
}

// MARK: - Data Processing

extension CoinOrderbookDataManager {
    private func calculateTotalOrderQuantity(
        orderbooks: [Orderbook],
        type: OrderbookType
    ) {
        let totalQuantity = orderbooks.compactMap { orderbook in
            Double(orderbook.quantity)
        }.reduce(0, +)
        
        
        
        delegate?.coinOrderbookDataManager(
            didCalculate: totalQuantity.roundedQuantity,
            type: type
        )
    }
    
    private func updateOrderbook(
        orderbooks: [Orderbook],
        to currentOrderbooks: inout [Orderbook],
        type : OrderbookType
    ) {
        var newOrderbooks: [String: Double] = [:]
        var oldOrderbooks: [String: Double] = [:]
        
        orderbooks.forEach { orderbook in
            newOrderbooks[orderbook.price] = Double(orderbook.quantity)
        }
        
        currentOrderbooks.forEach { orderbook in
            oldOrderbooks[orderbook.price] = Double(orderbook.quantity)
        }
        
        newOrderbooks.merge(oldOrderbooks) { (new, _) in new }
        
        let resultOrderbooks: [Orderbook] = newOrderbooks
            .filter { $0.value > 0 }
            .map { Orderbook(price: $0.key, quantity: String($0.value), type: type) }
            .sorted { $0.price > $1.price }
        
        if resultOrderbooks.count > 30 {
            currentOrderbooks = resultOrderbooks.dropLast(resultOrderbooks.count - 30)
            return
        }
        
        currentOrderbooks = resultOrderbooks
    }
}

// MARK: - HTTP Network

extension CoinOrderbookDataManager {
    func fetchOrderbook() {
        let api = OrderbookAPI(orderCurrency: symbol)
        
        httpNetworkService.fetch(
            api: api,
            type: OrderbookValueObject.self
        ) { [weak self] result in
            guard let orderbookValueObject = result.value else {
                self?.delegate?.coinOrderbookDataManagerDidFetchFail()
                print(result.error?.localizedDescription as Any)
                return
            }
            
            guard orderbookValueObject.status == "0000" else {
                return
            }
            
            self?.setOrderbooks(from: orderbookValueObject.orderbook)
        }
    }
    
    private func setOrderbooks(from orderbook: OrderbookData) {
        askOrderbooks = orderbook.asks.map {
            $0.generate(type: .ask)
        }.reversed()
        
        bidOrderbooks = orderbook.bids.map {
            $0.generate(type: .bid)
        }
    }
}

// MARK: - WebSocket Network

extension CoinOrderbookDataManager {
    func fetchOrderbookWebSocket() {
        let api = OrderBookDepthWebSocket(symbol: symbol)
        
        webSocketService.open(webSocketAPI: api) { [weak self] result in
            guard let message = result.value else {
                print(result.error?.localizedDescription as Any)
                return
            }
            
            switch message {
            case .string(let response):
                let orderbook = try? self?.parseWebSocketOrderbook(to: response)
                
                guard let orderbook = orderbook?.webSocketOrderBookDepthData else {
                    return
                }
                
                self?.insertOrderbook(orderbook)
            default:
                break
            }
        }
    }
    
    private func parseWebSocketOrderbook(
        to string: String
    ) throws -> WebSocketOrderBookDepthValueObject {
        do {
            let webSocketOrderbookValueObject = try JSONParser().decode(
                string: string,
                type: WebSocketOrderBookDepthValueObject.self
            )
            
            return webSocketOrderbookValueObject
        } catch {
            print(error.localizedDescription)
            
            throw error
        }
    }
    
    private func insertOrderbook(
        _ orderbooks: WebSocketOrderBookDepthData,
        at index: Int = Int.zero
    ) {
        let webSocketAskOrderbooks = orderbooks.asks.map {
            $0.generate()
        }
        
        updateOrderbook(orderbooks: webSocketAskOrderbooks, to: &askOrderbooks, type: .ask)
        
        let webSocketBidOrderbooks = orderbooks.bids.map {
            $0.generate()
        }

        updateOrderbook(orderbooks: webSocketBidOrderbooks, to: &bidOrderbooks, type: .bid)
    }
}

