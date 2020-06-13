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
    static var selectedResturantID = "selectedResturantID"
}

//****************************************************//
//MARK:- StoryBoard and ViewControllers
enum ViewControllersIdentifires: String {
    
    case intro_ViewController = "initialVC"
    case HomeScreen_ViewController = "homeVC"
}

enum StoryboardsIdentifires: String {
    
    case Main_Storyboard = "Main"
}

//****************************************************//
//MARK:- CoreData
enum CoreDataEntities: String {
    
    case Resturant = "ResturantEntity"
}

enum Resturant_Entity: String {
    case ID = "id"
    case Name = "name"
    case Category = "cat"
    case CategoryID = "catID"
    case Latitude = "lat"
    case Longitude = "lon"
    case ULatitude = "ulat"
    case ULongitude = "ulon"
    case Rating = "rating"
    case Link = "link"
    case OpenResturant = "openResturant"
    case Error = "error"
    case Images = "image"
}

//****************************************************//
//MARK:- Extensions
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
