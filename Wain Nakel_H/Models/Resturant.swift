//
//  Resturant.swift
//  Wain Nakel_H
//
//  Created by Hany Mahmoud on 5/25/20.
//  Copyright © 2020 Hany Mahmoud. All rights reserved.
//

import Foundation


struct Resturant: Codable {
    var error, name, id: String?
    var link: String?
    var cat, catID, rating, lat: String?
    var lon, ulat, ulon, openResturant: String?
    var image: [String]?

    enum CodingKeys: String, CodingKey {
        case error, name, id, link, cat
        case catID = "catId"
        case rating, lat, lon
        case ulat = "Ulat"
        case ulon = "Ulon"
        case openResturant = "open"
        case image
    }
}
