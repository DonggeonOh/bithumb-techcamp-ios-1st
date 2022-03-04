//
//  CoinListCollectionViewCell.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/02/24.
//

import UIKit

final class CoinListCollectionViewCell: UICollectionViewListCell {

    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var symbolPerCurrencyLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var changeRateLabel: UILabel!
    @IBOutlet private weak var changePriceLabel: UILabel!
    
    var toggleFavorite: () -> Void = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(item: Coin) {
        favoriteButton.isSelected = item.isFavorite
        nameLabel.text = item.callingName
        symbolPerCurrencyLabel.text = item.symbolPerKRW
        priceLabel.text = item.priceString
        changeRateLabel.text = item.changeRateString
        changePriceLabel.text = item.changePriceString
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        toggleFavorite()
    }
}
