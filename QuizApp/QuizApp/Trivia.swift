//
//  Trivia.swift
//  QuizApp
//
//  Created by 90307332 on 2/10/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import Foundation

struct Trivia: Codable {
    
    var response_code:Int?
    var results:[Question]?
}
