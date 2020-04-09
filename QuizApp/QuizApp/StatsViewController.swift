//
//  StatsViewController.swift
//  QuizApp
//
//  Created by 90307332 on 2/15/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import UIKit
import AVFoundation

class StatsViewController : UIViewController {
    
    var points: Int!
    var correct: Int!
    var streak: Int!
    
    // --- --- --- --- --- --- --- --- --- --- --- //
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    
    // --- --- --- --- --- --- --- --- --- --- --- //
    
    var exitButtonSound = AVAudioPlayer()
    
    // --- --- --- --- --- --- --- --- --- --- --- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pointsLabel.text = "\(points!)"
        correctLabel.text = "\(correct!)/20"
        streakLabel.text = "\(streak!)"
        
        let audioFile = Bundle.main.path(forResource: "Correct", ofType: ".mp3")
        try! exitButtonSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioFile!))
    }
    
    @IBAction func exitClicked(_ sender: UIButton) {
        exitButtonSound.play()
        self.performSegue(withIdentifier: "toHome", sender: nil)
    }
}
