//
//  Reason.swift
//  WhereTo
//
//  Created by Prateek Kansara on 04/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation

struct Reason{
    
    var count       : Int              = 0
    var items       : [ReasonItem]?
    
}

extension Reason : Codable{
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Reason.CodingKeys.self)
        count = try values.decode(Int.self, forKey: .count)
        items = try values.decode([ReasonItem].self, forKey: .items)
    }
}

