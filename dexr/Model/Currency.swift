//
//  Currency.swift
//  dexr
//
//  Created by ibrahim dağcı on 13.09.2023.
//

import Foundation

struct Currency: Codable{
    let success: Bool
    let timestamp: Int
    let base: String
    let date: String
    let rates: [String: Double]
}
