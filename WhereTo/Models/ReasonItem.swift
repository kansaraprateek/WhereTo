//
//  ReasonItem.swift
//  WhereTo
//
//  Created by Prateek Kansara on 04/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation

struct ReasonItem {
    var summary         : String?
    var type            : String?
    var reasonName      : String?
}

extension ReasonItem : Codable{
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ReasonItem.CodingKeys.self)
        summary = try values.decode(String.self, forKey: .summary)
        type = try values.decode(String.self, forKey: .type)
        reasonName = try values.decode(String.self, forKey: .reasonName)
    }
}
