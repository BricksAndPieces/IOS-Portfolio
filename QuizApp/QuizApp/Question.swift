//
//  Question.swift
//  QuizApp
//
//  Created by 90307332 on 2/10/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import Foundation

struct Question: Codable {
    
    var category:String?
    var difficulty:String?
    var question:String?
    var correct_answer:String?
    var incorrect_answers:[String]?
}
