//
//  GetServices.swift
//  Wain Nakel_H
//
//  Created by Hany Mahmoud on 5/25/20.
//  Copyright © 2020 Hany Mahmoud. All rights reserved.
//

import Foundation
import Alamofire
import SVProgressHUD

struct GetServices {
    
    static func generateResturant(long: String, lat: String, completion: @escaping(_ Resturant: Resturant?, _ errorMsg: String?) -> Void){
        
        SVProgressHUD.show()
        let URL = URLsConfig.generateResturant
        let coordinate = lat + "," + long
        print("start with url \(URL)")
        
        // Parameters is enum defined in URLsConfig file
        let parameters = [Parameters.resturantCoordinate.rawValue : coordinate]
        
        Alamofire.request(URL, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: nil).validate(statusCode: 200..<300).responseJSON { (response: DataResponse<Any>) in
            print("finish request")
            do {
                
                let resturant = try JSONDecoder().decode(Resturant.self, from: response.data!)
                
                SVProgressHUD.dismiss()
                completion(resturant, nil)
            }
            catch {
                
                SVProgressHUD.dismiss()
                print(error.localizedDescription)
                completion(nil, error.localizedDescription)
            }
        }
    }
}
