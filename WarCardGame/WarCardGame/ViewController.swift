//
//  ViewController.swift
//  WarCardGame
//
//  Created by 90307332 on 1/30/20.
//  Copyright © 2020 BricksAndPieces. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var leftCard: UIImageView!
    
    @IBOutlet weak var rightCard: UIImageView!
    
    @IBOutlet weak var leftScore: UILabel!
    
    @IBOutlet weak var rightScore: UILabel!
    
    var leftScr = 0;
    var rightScr = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dealButton(_ sender: Any) {
        let left = Int.random(in: 2...14);
        let right = Int.random(in: 2...14)
        
        leftCard.image = UIImage(named: "card\(left)")
        rightCard.image = UIImage(named: "card\(right)")
        
        if left > right {
            leftScr += 1
            leftScore.text = String(leftScr)
        }else if right > left {
            rightScr += 1
            rightScore.text = String(rightScr)
        }
    }
}
