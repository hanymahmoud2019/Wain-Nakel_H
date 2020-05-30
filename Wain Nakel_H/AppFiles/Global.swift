//
//  Global.swift
//  Wain Nakel_H
//
//  Created by Hany Mahmoud on 5/27/20.
//  Copyright © 2020 Hany Mahmoud. All rights reserved.
//

import Foundation

struct Global {
    
    static var resturantRate: String = "10"
}


enum ViewControllersIdentifires: String {
    
    case intro_ViewController = "initialVC"
    case HomeScreen_ViewController = "homeVC"
}

enum StoryboardsIdentifires: String {
    
    case Main_Storyboard = "Main"
}

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func convertToURL() -> URL? {
        guard let urlString = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        let url = URL(string: urlString)
        return url
    }
    
}
