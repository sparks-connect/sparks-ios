//
//  CountryCell.swift
//  Sparks
//
//  Created by George Vashakidze on 7/18/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

class CountryCell: TableViewCell {

    override var reuseIdentifier: String? { return "CountryCell" }

    @IBOutlet weak var lblFlag: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.lblFlag.text = nil
        self.lblCode.text = nil
        self.lblCountry.text = nil
    }
    
    override func configure(parameter: TableViewCellParameter?, delegate: TableViewCellDelegate?) {
        super.configure(parameter: parameter, delegate: delegate)
        guard let country = parameter as? Country else { return }
        
        self.lblFlag.text = country.emoji
        self.lblCode.text = country.code
        self.lblCountry.text = country.name
    }

}
