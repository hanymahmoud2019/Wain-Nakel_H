//
//  URLsConfig.swift
//  Wain Nakel_H
//
//  Created by Hany Mahmoud on 5/24/20.
//  Copyright © 2020 Hany Mahmoud. All rights reserved.
//

import Foundation

var BASE_URL = "https://wainnakel.com/api/v1/"

enum Parameters: String {
    
    case resturantCoordinate = "uid"
}

struct URLsConfig {
    
    static let generateResturant = BASE_URL + "GenerateFS.php"
}
