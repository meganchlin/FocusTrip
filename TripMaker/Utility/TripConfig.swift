//
//  Constants.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-21.
//

import Foundation
import UIKit

struct TripConfig {
 
    static let route_level: [String: Int] = [
        "Taiwan": 2,
        "South Korea": 3,
        "Canada": 5
    ]
    
    static let route_min_time: [String: Int] = [
        "Taiwan": 30,
        "South Korea": 60,
        "Canada": 120
    ]
    
    static let route_attractions: [String: [CGPoint]] = [
        "Taiwan" :
            [
                CGPoint(x: 400 - 125,y: 400 - 30),
                CGPoint(x: 400 - 125,y: 400 - 94),
                CGPoint(x: 400 - 230,y: 400 - 94),
                CGPoint(x: 400 - 318,y: 400 - 101),
                CGPoint(x: 400 - 318,y: 400 - 233),
                CGPoint(x: 400 - 212,y: 400 - 238),
                CGPoint(x: 400 - 180,y: 400 - 298),
                CGPoint(x: 400 - 55,y: 400 - 298)
            ],
        "South Korea" :
            [
                CGPoint(x: 400 - 100,y: 400 - 32),
                CGPoint(x: 400 - 339,y: 400 - 37),
                CGPoint(x: 400 - 341,y: 400 - 197),
                CGPoint(x: 400 - 220,y: 400 - 202),
                CGPoint(x: 400 - 52,y: 400 - 210),
                CGPoint(x: 400 - 54,y: 400 - 330),
                CGPoint(x: 400 - 250,y: 400 - 336),
            ],
        "Canada" :
            [CGPoint(x: 400 - 301,y: 400 - 210),
             CGPoint(x: 400 - 301,y: 400 - 158),
             CGPoint(x: 400 - 370,y: 400 - 147),
             CGPoint(x: 400 - 371,y: 400 - 16),
             CGPoint(x: 400 - 203,y: 400 - 16),
             CGPoint(x: 400 - 191,y: 400 - 88),
             CGPoint(x: 400 - 30,y: 400 - 97),
             CGPoint(x: 400 - 30,y: 400 - 183),
             CGPoint(x: 400 - 200,y: 400 - 192),
            ]
    ]

    static let route_segments: [String: [Int: [String: CGPoint]]] = [
        "Taiwan":
            [0 : ["startPoint": CGPoint(x: 400 - 125,y: 400 - 0), "endPoint": route_attractions["Taiwan"]![0], "controlPoint": calculateControlPoint(start: CGPoint(x: 400 - 125,y: 400 - 0), end: route_attractions["Taiwan"]![0], factor: 0)],
             1 : ["startPoint": route_attractions["Taiwan"]![0], "endPoint": route_attractions["Taiwan"]![1], "controlPoint": calculateControlPoint(start: route_attractions["Taiwan"]![0], end: route_attractions["Taiwan"]![1], factor: 0)],
             2 : ["startPoint": route_attractions["Taiwan"]![1], "endPoint": route_attractions["Taiwan"]![2], "controlPoint": calculateControlPoint(start: route_attractions["Taiwan"]![1], end: route_attractions["Taiwan"]![2], factor: 0)],
             3 : ["startPoint": route_attractions["Taiwan"]![2], "endPoint": route_attractions["Taiwan"]![3], "controlPoint": CGPoint(x:400 - 320, y:400 - 89)],
             4 : ["startPoint": route_attractions["Taiwan"]![3], "endPoint": route_attractions["Taiwan"]![4], "controlPoint": CGPoint(x:400 - 328, y:400 - 166)],
             5 : ["startPoint": route_attractions["Taiwan"]![4], "endPoint": route_attractions["Taiwan"]![5], "controlPoint": CGPoint(x:400 - 315, y:400 - 242)],
             6 : ["startPoint": route_attractions["Taiwan"]![5], "endPoint": route_attractions["Taiwan"]![6], "controlPoint": CGPoint(x:400 - 220, y:400 - 306)],
             7 : ["startPoint": route_attractions["Taiwan"]![6], "endPoint": route_attractions["Taiwan"]![7], "controlPoint": calculateControlPoint(start: route_attractions["Taiwan"]![6], end: route_attractions["Taiwan"]![7], factor: 0)],
             8 : ["startPoint": route_attractions["Taiwan"]![7], "endPoint": CGPoint(x: 400 - 15,y: 400 - 298), "controlPoint":
                calculateControlPoint(start: route_attractions["Taiwan"]![7], end: CGPoint(x: 400 - 15,y: 400 - 298), factor: 0)]],
        "South Korea":
            [0 : ["startPoint": CGPoint(x: 400 - 0,y: 400 - 32), "endPoint": route_attractions["South Korea"]![0], "controlPoint": calculateControlPoint(start: CGPoint(x: 400 - 0,y: 400 - 32), end: route_attractions["South Korea"]![0], factor: 0)],
             1 : ["startPoint": route_attractions["South Korea"]![0], "endPoint": route_attractions["South Korea"]![1], "controlPoint": CGPoint(x: 400 - 320,y: 400 - 24)],
             2 : ["startPoint": route_attractions["South Korea"]![1], "endPoint": route_attractions["South Korea"]![2], "controlPoint": CGPoint(x: 400 - 353,y: 400 - 107)],
             3 : ["startPoint": route_attractions["South Korea"]![2], "endPoint": route_attractions["South Korea"]![3], "controlPoint": CGPoint(x: 400 - 353,y: 400 - 208)],
             4 : ["startPoint": route_attractions["South Korea"]![3], "endPoint": route_attractions["South Korea"]![4], "controlPoint": CGPoint(x: 400 - 55,y: 400 - 197)],
             5 : ["startPoint": route_attractions["South Korea"]![4], "endPoint": route_attractions["South Korea"]![5], "controlPoint": CGPoint(x: 400 - 42,y: 400 - 270)],
             6 : ["startPoint": route_attractions["South Korea"]![5], "endPoint": route_attractions["South Korea"]![6], "controlPoint": CGPoint(x: 400 - 48,y: 400 - 340)],
             7 : ["startPoint": route_attractions["South Korea"]![6], "endPoint": CGPoint(x: 400 - 385,y: 400 - 336), "controlPoint": CGPoint(x: 400 - 317,y: 400 - 336)]
            ],
        "Canada":
            [0 : ["startPoint": CGPoint(x: 400 - 385,y: 400 - 216), "endPoint": route_attractions["Canada"]![0], "controlPoint": calculateControlPoint(start: CGPoint(x: 400 - 310,y: 400 - 228), end: route_attractions["Canada"]![0], factor: 0)],
             1 : ["startPoint": route_attractions["Canada"]![0], "endPoint": route_attractions["Canada"]![1], "controlPoint": CGPoint(x: 400 - 285,y: 400 - 184)],
             2 : ["startPoint": route_attractions["Canada"]![1], "endPoint": route_attractions["Canada"]![2], "controlPoint": CGPoint(x: 400 - 335,y: 400 - 152)],
             3 : ["startPoint": route_attractions["Canada"]![2], "endPoint": route_attractions["Canada"]![3], "controlPoint": CGPoint(x: 400 - 385,y: 400 - 80)],
             4 : ["startPoint": route_attractions["Canada"]![3], "endPoint": route_attractions["Canada"]![4], "controlPoint": CGPoint(x: 400 - 287,y: 400 - 0)],
             5 : ["startPoint": route_attractions["Canada"]![4], "endPoint": route_attractions["Canada"]![5], "controlPoint": CGPoint(x: 400 - 197,y: 400 - 51)],
             6 : ["startPoint": route_attractions["Canada"]![5], "endPoint": route_attractions["Canada"]![6], "controlPoint": CGPoint(x: 400 - 110,y: 400 - 92)],
             7 : ["startPoint": route_attractions["Canada"]![6], "endPoint": route_attractions["Canada"]![7], "controlPoint": CGPoint(x: 400 - 15,y: 400 - 140)],
             8 : ["startPoint": route_attractions["Canada"]![7], "endPoint": route_attractions["Canada"]![8], "controlPoint": CGPoint(x: 400 - 115,y: 400 - 187)],
             9 : ["startPoint": route_attractions["Canada"]![8], "endPoint": CGPoint(x: 400 - 208,y: 400 - 270), "controlPoint": CGPoint(x: 400 - 210,y: 400 - 187)],
            ]
    ]
    
    static let route_animation: [String: [Int: Bool]] = [
        "Taiwan": [0 : true, 1 : true, 2 : true, 3 : true, 4 : false, 5 : false, 6 : false, 7 : false, 8: false],
        "South Korea": [0 : true, 1 : true, 2: false, 3: false, 4: false, 5: true, 6: true, 7: true],
        "Canada": [0 : false, 1 : true, 2 : true, 3 : false, 4 : false, 5 : false, 6 : false, 7 : true, 8 : true, 9 : false]
    ]
    
}

