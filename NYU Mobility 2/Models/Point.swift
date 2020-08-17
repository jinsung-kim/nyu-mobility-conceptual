//
//  Point.swift
//  NYU Mobility 2
//
//  Created by Jin Kim on 8/10/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import Foundation

public struct Point: Codable { // Without 'Codable', it will not turn into a JSON
    var time: String
    var steps: Int32
    var distance: Int32
    var coordinates: [String: [Double]] // All lat, long values held in the same place
//    var gyroData: [String: [Double]] // All x values held in the same place, y values, z values
    var avgPace: Double
    var currPace: Double
    var currCad: Double
    
    // Used to add each point within the JSON
    init(_ time: String, _ steps: Int32, _ distance: Int32, _ avgPace: Double, _ currPace: Double,
         _ currCad: Double, _ coordinates: [String: [Double]]) {
        // _ gyroData: [String: [Double]]
        self.time = time
        self.steps = steps
        self.coordinates = coordinates
//        self.gyroData = gyroData
        self.currCad = currCad
        self.avgPace = avgPace
        self.currPace = currPace
        self.distance = distance
    }
    
    func convertToDictionary() -> [String : Any] {
//        let dic: [String: Any] = ["time": self.time, "steps": self.steps, "distance": self.distance,
//                                  "coordinates": self.coordinates, "gyroData": self.gyroData,
//                                  "avgPace": self.avgPace, "currPace": self.currPace,
//                                  "currCad": self.currCad]
        let dic: [String: Any] = ["time": self.time, "steps": self.steps, "distance": self.distance,
                                  "coordinates": self.coordinates, "avgPace": self.avgPace, "currPace": self.currPace,
                                  "currCad": self.currCad]
        return dic
    }
}
