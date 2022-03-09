//
//  Transaction.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/01.
//

import Foundation

enum TransactionType {
    case bid
    case ask
}

struct Transaction: Hashable {
    
    // MARK: - Property
    
    private(set) var date: String
    private(set) var type: TransactionType
    private(set) var price: String
    private(set) var quantity: String
    private let uuid: UUID = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

// MARK: - Computed Property

extension Transaction {
    var convertedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let date = formatter.date(from: date) else {
            return String()
        }
        
        formatter.dateFormat = "HH:mm:ss"
        
        return formatter.string(from: date)
    }
    
    var commaPrice: String {
        return Double(price)?.commaPrice ?? "오류 발생"
    }
    
    var roundedQuantity: String {
        return Double(quantity)?.roundedQuantity ?? "오류 발생"
    }
}
