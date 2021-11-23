//
//  CardTag.swift
//  Sparks
//
//  Created by George Vashakidze on 4/15/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

class CardTag: Decodable {
    let id: String
    let title: String
    let bgColor: UIColor
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case bgColor
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        let colorString = try container.decode(String.self, forKey: .bgColor)
        self.bgColor = UIColor.init(hex: colorString)
    }
}
