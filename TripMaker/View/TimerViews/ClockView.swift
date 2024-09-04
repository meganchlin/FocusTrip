//
//  ClockView.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-27.
//

import SwiftUI

struct ClockView: View {
    @Binding var timeRemaining: TimeInterval

    var body: some View {
        Text(timeToString(timeRemaining))
            .font(.system(size: 30, weight: .heavy, design: .rounded))
    }

    func timeToString(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}

#Preview {
    ClockView(timeRemaining: .constant(3907)) // 1 hour, 5 minutes, and 7 seconds
        .previewLayout(.sizeThatFits)
        .padding()
}
