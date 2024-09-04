//
//  ProgressTrackView.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-27.
//

import SwiftUI

struct ProgressTrackView: View {
    var body: some View {
        GeometryReader { geometry in
            Circle()
                .fill(Color.clear)
                .overlay(Circle().stroke(Color.gray, lineWidth: 15))
                .frame(width: geometry.size.width / 2, height: geometry.size.height / 2)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

#Preview {
    ProgressTrackView()
}
