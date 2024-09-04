//
//  ProgressBarView.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-27.
//

import SwiftUI

struct ProgressBarView: View {
    var counter: Int
    var countTo: Int
    var color1: Color = .orange
    var color2: Color = .red

    var body: some View {
        GeometryReader { geometry in
            Circle()
                .trim(from: 0, to: progress())
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [color2, color1, color1, color2]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * progress())
                    ),
                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                )
                .animation(.easeInOut(duration: 1), value: progress())
                .rotationEffect(Angle(degrees: -90))
                .frame(width: geometry.size.width / 2, height: geometry.size.height / 2)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }

    func progress() -> CGFloat {
        return CGFloat(counter) / CGFloat(countTo)
    }
}

#Preview {
    ProgressBarView(counter: 75, countTo: 120)
        .previewLayout(.fixed(width: 250, height: 250))
        .padding()
}
