//
//  SecondViewController.swift
//  QuizApp
//
//  Created by 90307332 on 2/10/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import UIKit
import AVFoundation

class SecondViewController: UIViewController {
    
    static var triviaGlobal:Trivia? = nil
    var trivia:Trivia? = triviaGlobal
    
    // --- --- --- --- --- --- --- --- --- --- --- --- //
    
    var questionNum = 0
    var score = 0
    var answerStreak = 0
    
    // --- --- --- --- --- --- --- --- --- --- --- --- //
    
    var correct = 0
    var maxAnswerStreak = 0
    var startTime: DispatchTime?
    
    // --- --- --- --- --- --- --- --- --- --- --- --- //
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    // --- --- --- --- --- --- --- --- --- --- --- --- //
    
    @IBOutlet weak var answer1: UIButton!
    @IBOutlet weak var answer2: UIButton!
    @IBOutlet weak var answer3: UIButton!
    @IBOutlet weak var answer4: UIButton!
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    // --- --- --- --- --- --- --- --- --- --- --- --- //
    
    var correctSound = AVAudioPlayer()
    var wrongSound = AVAudioPlayer()
    
    // --- --- --- --- --- --- --- --- --- --- --- --- //
    
    @IBAction func answerClicked(_ sender: UIButton) {
        checkAnswer(sender.titleLabel!.text!)
    }
    
    // --- --- --- --- --- --- --- --- --- --- --- --- //

    override func viewDidLoad() {
        super.viewDidLoad()
        SecondViewController.triviaGlobal = nil
        
        // Initialize sounds
        let correctSoundFile = Bundle.main.path(forResource: "Correct", ofType: ".mp3")
        let wrongSoundFile = Bundle.main.path(forResource: "Wrong", ofType: ".mp3")
        try! correctSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: correctSoundFile!))
        try! wrongSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: wrongSoundFile!))

        // Setup progress bar
        progressBar.progress = 0.0
        progressBar.layer.cornerRadius = 5
        progressBar.clipsToBounds = true
        progressBar.layer.sublayers![1].cornerRadius = 5
        progressBar.subviews[1].clipsToBounds = true
        
        // Setup labels
        pointsLabel.text = String(score)
        
        // Setup first question
        setupQuestion()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let statsViewController = segue.destination as! StatsViewController
        statsViewController.points = score
        statsViewController.correct = correct
        statsViewController.streak = max(maxAnswerStreak, answerStreak)
    }
    
    // --- --- --- --- --- --- --- --- --- --- --- --- //

    func setupQuestion() {
        let questionObj = trivia?.results![questionNum]
        var answers:[String] = (questionObj?.incorrect_answers)!
        answers.append((questionObj?.correct_answer)!)
        answers.shuffle()
        
        // Display the question
        questionLabel.text = decodeHtml((questionObj?.question)!)
        
        // Display the answers
        answer1.setTitle(decodeHtml(answers[0]), for: .normal)
        answer2.setTitle(decodeHtml(answers[1]), for: .normal)
        answer3.setTitle(decodeHtml(answers[2]), for: .normal)
        answer4.setTitle(decodeHtml(answers[3]), for: .normal)
        
        // Category label (getting rid of some extra words cause they look ugly)
        categoryLabel.text = questionObj!.category!
            .replacingOccurrences(of: "Entertainment: ", with: "")
            .replacingOccurrences(of: "Science: ", with: "")
        
        questionNum += 1
        progressBar.setProgress(Float(questionNum) / Float((trivia?.results?.count)!), animated: true)
        startTime = DispatchTime.now()
    }
    
    func nextQuestion() {
        if(self.questionNum < (self.trivia?.results!.count)!) {
            self.setupQuestion()
        }else {
            self.performSegue(withIdentifier: "toStats", sender: nil)
        }
    }
    
    // Rubbish code but it works
    func checkAnswer(_ answer: String) {
        if(answer == decodeHtml((trivia?.results![questionNum-1].correct_answer)!)) {
            correctSound.play()
            let alert = UIAlertController(title: "Correct", message: "Good job!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Next Question", style: .default, handler: { action in
                self.nextQuestion()
            })
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
            updateScore(true)
            correct += 1
        }else {
            wrongSound.play()
            let alert = UIAlertController(title: "Incorrect", message: "Correct Answer: \(decodeHtml(trivia!.results![questionNum-1].correct_answer!))", preferredStyle: .alert)
            let action = UIAlertAction(title: "Next Question", style: .default, handler: { action in
                self.nextQuestion()
            })
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
            maxAnswerStreak = max(maxAnswerStreak, answerStreak)
            updateScore(false)
        }
    }
    
    // --- --- --- --- --- --- --- --- --- --- --- --- //
    
    func updateScore(_ correct: Bool) {
        let baseScore = correct ? 100 : -50
        let answerStreakScore = correct ? answerStreak * 50 : 0
        self.answerStreak = correct ? answerStreak+1 : 0
        
        var difficultyScore = 0
        switch (trivia?.results![questionNum-1].difficulty!)! {
            case "easy":
                difficultyScore = correct ? 10 : -30
                break
            case "medium":
                difficultyScore = correct ? 20 : -30
                break
            case "hard":
                difficultyScore = correct ? 30 : -10
                break
            default: difficultyScore = 0
        }
        
        let timeTakenNano = DispatchTime.now().uptimeNanoseconds - startTime!.uptimeNanoseconds
        let timeTakenSec = min(Double(timeTakenNano) / 1_000_000_000, 5)
        let timeTakenScore = correct ? Int((5-timeTakenSec) * 100) : 0
        
        let oldScore = score
        score = max(score+baseScore+answerStreakScore+difficultyScore+timeTakenScore, 0)
        incrementScore(from: oldScore, to: score)
    }

    func incrementScore(from start: Int, to end: Int) {
        if start != 0 || end != 0 {
            let opposite = start > end
            incrementLabel(opposite ? Array((end ..< start+1).reversed()) : Array(start ..< end+1), 0.5)
        }
    }
    
    func incrementLabel(_ range:[Int], _ duration: Double) {
        DispatchQueue.global().async {
            for i in range {
                let sleep = abs(Double(range[range.count-1]-range[0]))
                usleep(UInt32(duration/sleep * 1000000.0))
                DispatchQueue.main.async {
                    self.pointsLabel.text = "\(i)"
                }
            }
        }
    }
    
    // --- --- --- --- --- --- --- --- --- --- --- --- //
    
    func decodeHtml(_ html: String) -> String {
        guard let data = html.data(using: .utf8) else {
            print("Error decoding html from API")
            return nil!
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let decoded = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            print("Error decoding html from API")
            return nil!
        }
        
        return decoded.string
    }
}
