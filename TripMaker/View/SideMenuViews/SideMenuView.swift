//
//  SideMenuView.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-20.
//

import SwiftUI

enum SideMenuRowType: Int, CaseIterable{
    case map = 0
    case stats
    case profile
    case passport
    
    var title: String {
        switch self {
        case .map:
            return "Map"
        case .stats:
            return "Stats"
        case .profile:
            return "Profile"
        case .passport:
            return "Passport"
        }
    }
    
    var imageIcon: String {
        switch self {
        case .map:
            return "globe.americas.fill"
        case .stats:
            return "chart.bar"
        case .profile:
            return "person.crop.circle"
        case .passport:
            return "person.text.rectangle"
        }
    }


}

struct SideMenuView: View {
    
    @Binding var selectedTab: Int
    @Binding var showSideMenu: Bool
    private var userProfile: UserProfile? {
        UserPreferences.userProfile
    }
    let dbManager = DBManager.shared
    let userName = UserPreferences.userName
    
    var body: some View {
        HStack {
            
            ZStack{
                Rectangle()
                    .fill(.white)
                    .frame(width: 270)
                    .shadow(color: .gray, radius: 5, x: 0, y: 3)
                
                
                VStack(alignment: .leading, spacing: 0) {
                    ProfileHeaderView(userProfile: userProfile)
                        .frame(height: 140)
                        .padding(.bottom, 30)
                    
                    ForEach(SideMenuRowType.allCases, id: \.self) { row in
                        MenuOptionView(
                            isSelected: selectedTab == row.rawValue,
                            imageName: row.imageIcon,
                            title: row.title,
                            action: {
                                selectedTab = row.rawValue
                                showSideMenu.toggle()
                            }
                        )
                    }
                    
                    Spacer()
                }
                .padding(.top, 100)
                .frame(width: 270)
                .background(
                    Color.white
                )
            }
            
            
            Spacer()
        }
        .background(.clear)
    }


}



#Preview {
    SideMenuView(selectedTab: .constant(0), showSideMenu: .constant(true))
}
