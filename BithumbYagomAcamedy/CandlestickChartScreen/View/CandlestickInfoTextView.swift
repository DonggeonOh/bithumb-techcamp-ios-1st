//
//  CandlestickInfoTextView.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/10.
//

import UIKit

final class CandlestickInfoTextView: UITextView {
    func update(price: CandlestickPrice) {
        let priceColor: UIColor
        
        if price.isIncreasePrice {
            priceColor = .red
        } else if price.isDecreasePrice {
            priceColor = .blue
        } else {
            priceColor = .label
        }
        
        attributedText = updatePriceTextColor(to: priceColor, price: price)
    }
    
    private func updatePriceTextColor(
        to color: UIColor, price: CandlestickPrice
    ) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: price.priceString)
        let prices = [Int(price.open), Int(price.high), Int(price.low), Int(price.close)]
        let text = price.priceString
        
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.label,
            range: (text as NSString).range(of: text)
        )
        
        prices.forEach { price in
            attributedString.addAttribute(
                .foregroundColor,
                value: color,
                range: (text as NSString).range(of: "\(price)")
            )
        }
        
        return attributedString
    }
}
