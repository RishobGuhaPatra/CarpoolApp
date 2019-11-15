//
//  CustomTabBarController.swift
//  Carpool
//
//  Created by Kartis.io on 8/10/18.
//  Copyright © 2018 Kartis.io. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.selectedIndex = 1
    }
    
}
