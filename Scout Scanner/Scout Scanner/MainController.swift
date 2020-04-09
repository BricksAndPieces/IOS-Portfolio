//
//  MainController.swift
//  Scout Scanner
//
//  Created by 90307332 on 2/21/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MainController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().reference().childByAutoId().child("Hello").setValue(["code", "90123"])
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toQRCode", sender: nil)
    }
}
