//
//  FirstViewController.swift
//  QuizApp
//
//  Created by 90307332 on 2/10/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import UIKit
import AVFoundation

class FirstViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    static var lastCategory = 11
    static var loading = false
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
    
    let numberOfQuestions = 20
    let categoryOptions:[String] = Array(APIArgs.categories.keys).sorted { $0 < $1 }
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
    
    var startButtonSound = AVAudioPlayer()
    var activityIndictor = UIActivityIndicatorView()
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
    
    @IBAction func startButton(_ sender: UIButton) {
        if !FirstViewController.loading {
            FirstViewController.lastCategory = categoryPicker.selectedRow(inComponent: 0)
            let categoryArg = APIArgs.categories[categoryOptions[FirstViewController.lastCategory]]!
            let apiUrl = "https://opentdb.com/api.php?amount=\(numberOfQuestions)&type=multiple\(categoryArg)"
            
            startButtonSound.play()
            activityIndictor.startAnimating()
            FirstViewController.loading = true
            loadTrivia(apiUrl)
        }
    }
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize category selector
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryPicker.selectRow(FirstViewController.lastCategory, inComponent: 0, animated: true)
        
        // Initialize sounds
        let soundFile = Bundle.main.path(forResource: "Correct", ofType: ".mp3")
        try! startButtonSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundFile!))
        
        // Create a loading indicator
        activityIndictor.center = self.view.center
        activityIndictor.hidesWhenStopped = true
        activityIndictor.style = UIActivityIndicatorView.Style.large
        view.addSubview(activityIndictor)
    }
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryOptions[row]
    }
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
    
    func loadTrivia(_ urlString: String) {
       print(urlString)
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if(data != nil && error == nil) {
                    let decoder = JSONDecoder()
                    do {
                        SecondViewController.triviaGlobal = try decoder.decode(Trivia.self, from: data!)
                        DispatchQueue.main.async {
                            self.activityIndictor.stopAnimating()
                            FirstViewController.loading = false
                            self.performSegue(withIdentifier: "toQuestions", sender: nil)
                        }
                    }catch {
                        print("Error in JSON parsing")
                    }
                }else {
                    DispatchQueue.main.async {
                        self.activityIndictor.stopAnimating()
                        FirstViewController.loading = false
                        
                        let alert = UIAlertController(title: "Error", message: "Could not access trivia API", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }.resume()
        }
    }
}
