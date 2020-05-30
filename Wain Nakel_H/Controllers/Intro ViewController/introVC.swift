//
//  ViewController.swift
//  Wain Nakel_H
//
//  Created by Hany Mahmoud on 5/24/20.
//  Copyright © 2020 Hany Mahmoud. All rights reserved.
//

import UIKit
import Spring

class introVC: UIViewController {
    
    //MARK:- OutLets
    
    @IBOutlet weak var btnSuggest: SpringButton!
    @IBOutlet weak var btnSettings: SpringButton!
    @IBOutlet weak var imgSettings: SpringImageView!
    //******************************************
    
    
    //MARK:- Delegate Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        animateButtons()
    }
    //******************************************
    

    //MARK:- Actions
    
    @IBAction func btnSuggest_Click(_ sender: UIButton) {
        
        // Navigate to home screen using navigation controller
        // ViewControllersIdentifires is enum defined in separated file "Global" in AppFiles
        let targetVC = UIStoryboard(name: StoryboardsIdentifires.Main_Storyboard.rawValue, bundle: .none).instantiateViewController(withIdentifier: ViewControllersIdentifires.HomeScreen_ViewController.rawValue) as? HomeVC
        self.navigationController?.pushViewController(targetVC!, animated: true)
        
    }
    //******************************************
    
}


//MARK:- Functions

extension introVC {
    
    func setupView(){
        
        // To hide Navigation Controller Bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Update UI
        btnSuggest.layer.cornerRadius = 8
        btnSuggest.clipsToBounds = true
        btnSuggest.setTitle("SuggestText".localized, for: .normal)
        
        btnSettings.layer.cornerRadius = 8
        btnSettings.clipsToBounds = true
    }
    
    func animateButtons(){
        
        btnSuggest.animation = Spring.AnimationPreset.SqueezeLeft.rawValue
        btnSuggest.duration = 1.5
        btnSuggest.animate()
        
        btnSettings.animation = Spring.AnimationPreset.SqueezeRight.rawValue
        btnSettings.duration = 1.5
        btnSettings.animate()
        
        imgSettings.animation = Spring.AnimationPreset.SqueezeRight.rawValue
        imgSettings.duration = 1.5
        imgSettings.animate()
    }
}
