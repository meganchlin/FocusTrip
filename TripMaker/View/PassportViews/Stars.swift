//
//  Stars.swift
//  TripMaker
//
//  Created by Megan Lin on 4/3/24.
//

import SwiftUI

struct Stars: View {
    
    var star: Int
    
    var body: some View {
        HStack(spacing: 5) {
            
            ForEach(1...star, id: \.self) { e in
                Image(systemName: "star.fill")
                    .foregroundColor(Color.yellow)
                    .font(.caption)
                }
            if star < 5 {
                
                let e = 5 - star
                ForEach(1...e, id: \.self) { e in
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.gray)
                        .font(.caption)
                }
            }
        }
    }
}

#Preview {
    Stars(star: 4)
}
