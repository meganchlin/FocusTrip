//
//  CircularChartView.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-04-06.
//

import SwiftUI

struct CircularChartView: View {
    var data: [CGFloat]
    var labels: [String]
    var maxValue: CGFloat
    
    let darkGreen = Color(UIColor(red: 143/256, green: 188/256, blue: 143/256, alpha: 0.5))
    let brightGreen = Color(UIColor(red: 0, green: 0.6, blue: 0.1, alpha: 0.8))

    private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 10), count: 7)
    
    var body: some View {
        let safeMaxValue = max(maxValue, 1)

        LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
            ForEach(Array(zip(labels.indices, data)), id: \.0) { index, value in
                VStack {
                    ZStack {
                        Circle()
                            .stroke(darkGreen, lineWidth: 10)
                            .frame(width: 40, height: 40)
                            
                        Circle()
                            .trim(from: 0, to: value / safeMaxValue)
                            .stroke(brightGreen, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .frame(width: 40, height: 40)
                            .rotationEffect(Angle(degrees: -90))
                        
                        Text("\(String(Int(value)))")
                            .font(.caption)
                            .foregroundColor(.black)
                            .scaledToFit()
                    }
                    Text(labels[index])
                        .font(.caption)
                        .lineLimit(1)
                }
                .padding(.bottom)
            }
        }
        .padding()
    }
}

#Preview {
    CircularChartView(
        data: Array(repeating: 5, count: 28),
        labels: (0..<24).map { String(format: "%02d:00", $0 % 24) },
        maxValue: 10
    )
    .previewLayout(.sizeThatFits)
    .previewDisplayName("Day Selection")

}
