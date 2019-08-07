//
//  Response.swift
//  WhereTo
//
//  Created by Prateek Kansara on 04/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation

struct Response  {
    var warning     : Warning?
    var groups      : [Group]?
    
}

extension Response : Codable{
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Response.CodingKeys.self)
        warning = try? values.decode(Warning.self, forKey: .warning)
        groups = try values.decode([Group].self, forKey: .groups)
    }
}
