//
//  Directions.swift
//  wkswift
//
//  Created by Marshall Thames on 4/25/25.
//

import Foundation

struct Offset {
    let u: Int
    let v: Int
}

let Direction: [Offset] = [
    Offset(u: 0, v: -1),  // up
    Offset(u: 1, v: -1),  // right, up
    Offset(u: 1, v: 0),   // right
    Offset(u: 1, v: 1),   // right, down
    Offset(u: 0, v: 1),   // down
    Offset(u: -1, v: 1),  // left, down
    Offset(u: -1, v: 0),  // left
    Offset(u: -1, v: -1)  // left, up
]
