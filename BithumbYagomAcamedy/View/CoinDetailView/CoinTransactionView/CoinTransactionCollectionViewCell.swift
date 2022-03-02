//
//  TransactionCollectionViewCell.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/01.
//

import UIKit

final class CoinTransactionCollectionViewCell: UICollectionViewListCell {
    
    // MARK: - Static Property
    static let identifier = "CoinTransactionCollectionViewCell"
    
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var quantityLabel: UILabel!
    
    // MARK: - Method
    
    func update(_ item: Transaction) {
        dateLabel.text = item.convertedDate
        priceLabel.text = item.commaPrice
        quantityLabel.text = item.roundedQuantity
        priceLabel.textColor = labelColor(type: item.type)
        quantityLabel.textColor = labelColor(type: item.type)
    }
    
    private func labelColor(type: TransactionType) -> UIColor {
        return type == .bid ? UIColor.systemRed : UIColor.systemBlue
    }
}
