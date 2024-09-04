//
//  RouteView.swift
//  TripMaker
//
//  Created by Megan Lin on 3/20/24.
//

import SwiftUI

struct RouteView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var route: String
    @State var locations: [String] = []
    @State var isPresented = false
    @State var selectedLocation = ""
    
    var body: some View {

        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.green.opacity(0.3), Color.yellow.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            Image("passport-background")
                .resizable()
                //.scaledToFill()
                .opacity(0.3)
                .ignoresSafeArea()

            ScrollView {
                VStack {
                    ForEach(locations, id: \.self) { location in
                        Button(action: {
                            self.isPresented = true
                            self.selectedLocation = location
                        }) {
                            BigCardView(location: location)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .frame(height: 270)
                            .background(BlurView(style: .regular))
                            .cornerRadius(10)
                            .padding(.vertical,6)
                            .padding(.horizontal)
                        }
                    }
                    .navigationDestination(isPresented: $isPresented) {
                        LocationView(location: selectedLocation)
                    }
                }
                    
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading, content: {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.backward.circle")
                        .font(.title2)
                })
            })
        }

        .onAppear {
            DispatchQueue.main.async {
                let db = DBManager.shared
                do {
                    // let routeDetail = try db.fetchRouteDetails(route: route)
                    self.locations = try db.fetchUnlockedLocations(routeName: route)
                    print("location: ", self.locations)
                } catch {
                    print("Route View Database operation failed: \(error)")
                }
            }
        }
    }
}

#Preview {
    RouteView(route: "Taiwan")
}
