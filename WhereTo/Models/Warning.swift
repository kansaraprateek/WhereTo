//
//  Warning.swift
//  WhereTo
//
//  Created by Prateek Kansara on 04/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation

struct Warning : Codable{
    var text        : String?
    
//    enum CodingKeys: String, CodingKey {
//        case text
//    }
}

//extension Warning : Encodable{}
//extension Warning : Codable{
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        text = try values.decode(String.self, forKey: .text)
//    }
//}
