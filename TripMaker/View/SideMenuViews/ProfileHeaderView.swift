//
//  ProfileHeaderView.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-20.
//

import SwiftUI

struct ProfileHeaderView: View {
    let dbManager = DBManager.shared
    var userProfile: UserProfile?
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                Spacer()
                if let userProfile = userProfile, let profileImage = imageFromString(userProfile.image) {
                    profileImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(.purple.opacity(0.7), lineWidth: 6)
                        )
                        .cornerRadius(50)
                } else {
                    // pic in asset as avatar
                    Image("profilePic")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(.purple.opacity(0.7), lineWidth: 6)
                        )
                        .cornerRadius(50)
                }
                Spacer()
            }
            
            if let userProfile = userProfile {
                Text(userProfile.username)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            } else {
                Text("Loading...")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }

        }
        .padding(.horizontal)
        .frame(width: 250)
        .background(Color.white)
        .cornerRadius(10)
    }
}


#Preview {
    ProfileHeaderView()
}
