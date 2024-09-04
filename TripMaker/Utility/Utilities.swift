//
//  Utilities.swift
//  TripMaker
//
//  Created by Megan Lin on 3/19/24.
//

import Foundation
import UIKit
import SwiftUI


extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }

    static public func ==(lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

func imageFromString(_ strPic: String) -> Image? {
    if let picImageData = Data(base64Encoded: strPic, options: .ignoreUnknownCharacters) {
        if let picImage = UIImage(data: picImageData) {
            let swiftUIImage = Image(uiImage: picImage)
            return swiftUIImage
        }
    }
    return nil
}

func stringFromImage(_ imagePic: UIImage) -> String {
    let picImageData: Data = imagePic.jpegData(compressionQuality: 0.6)!
    let picBase64 = picImageData.base64EncodedString()
    return picBase64
}

extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
    }
}

func calculateControlPoint(start: CGPoint, end: CGPoint, factor: CGFloat) -> CGPoint {
    // Calculate midpoint
    let midpoint = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
    
    // Calculate adjustment vector (perpendicular to the line connecting start and end points)
    let dx = end.x - start.x
    let dy = end.y - start.y
    let adjustmentVector = CGPoint(x: -dy, y: dx)
    
    // Normalize adjustment vector
    let magnitude = sqrt(adjustmentVector.x * adjustmentVector.x + adjustmentVector.y * adjustmentVector.y)
    let normalizedAdjustmentVector = CGPoint(x: adjustmentVector.x / magnitude, y: adjustmentVector.y / magnitude)
    
    // Scale and adjust the midpoint by the factor
    let controlPoint = CGPoint(x: midpoint.x + normalizedAdjustmentVector.x * factor, y: midpoint.y + normalizedAdjustmentVector.y * factor)
    
    return controlPoint
}

// Calculate a point along a quadratic Bézier curve
func pointOnQuadraticBezier(startPoint: CGPoint, controlPoint: CGPoint, endPoint: CGPoint, progress: Double) -> CGPoint {
    let t = CGFloat(progress)
    let oneMinusT = 1 - t
    
    // Bézier formula
    let x = oneMinusT * oneMinusT * startPoint.x + 2 * oneMinusT * t * controlPoint.x + t * t * endPoint.x
    let y = oneMinusT * oneMinusT * startPoint.y + 2 * oneMinusT * t * controlPoint.y + t * t * endPoint.y
       
    return CGPoint(x: x, y: y)
}
