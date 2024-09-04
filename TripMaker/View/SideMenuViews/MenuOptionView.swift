//
//  MenuOptionView.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-20.
//

import SwiftUI

struct MenuOptionView: View {
    let isSelected: Bool
    let imageName: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Rectangle()
                    .fill(isSelected ? .orange : .clear)
                    .frame(width: 5)
                
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(isSelected ? .black.opacity(0.8) : .gray)
                    .frame(width: 26, height: 26)
                
                Text(title)
                    .font(Font.custom("Bradley Hand", size: 20))
                    .foregroundColor(isSelected ? .black : .gray)
                
                Spacer()
            }
            .frame(height: 50)
            .cornerRadius(10)
            .background(
                LinearGradient(colors: [isSelected ? .orange.opacity(0.5) : .white, .white], startPoint: .leading, endPoint: .trailing)
                    .cornerRadius(10)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MenuOptionView(isSelected: true, imageName: "person.crop.circle", title: "Profile", action: {})
}
