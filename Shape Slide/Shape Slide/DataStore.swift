//
//  DataStore.swift
//  Shape Slide
//
//  Created by 90307332 on 3/19/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import UIKit

class DataStore {
    
    public static func getLevel() -> Int {
        let level = UserDefaults.standard.value(forKey: "Level")
        return level == nil ? 0 : level as! Int
    }
    
    public static func setLevel(level: Int) {
        UserDefaults.standard.setValue(level, forKey: "Level")
        UserDefaults.standard.synchronize()
    }
}
