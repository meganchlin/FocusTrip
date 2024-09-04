//
//  ContentView.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-16.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State var routes: [String] = initData()
    
    @State var presentSideMenu = false
    @State var selectedSideMenuTab = 0
    
    
    var body: some View {
        ZStack{
            Group {
                switch selectedSideMenuTab {
                case 0:
                    MapView(showSideMenu: $presentSideMenu)
                case 1:
                    StatsView(presentSideMenu: $presentSideMenu)
                case 2:
                    ProfileView(presentSideMenu: $presentSideMenu)
                case 3:
                    PassportView(presentSideMenu: $presentSideMenu)
                default:
                    Text("Selection does not correspond to a tab view.")
                }
            }
            
            SideMenu(isShowing: $presentSideMenu, content: AnyView(SideMenuView(selectedTab: $selectedSideMenuTab, showSideMenu: $presentSideMenu)))
        }
    }
    
}

func initData() -> [String] {
    var routes: [String] = []
    
    print("called")
    let db = DBManager.shared
    do {
        routes = try db.fetchAllRoutes()
        print(routes)
    } catch {
        print("Content View Database operation failed: \(error)")
    }
    return routes
}

#Preview {
    ContentView()
}
