//
//  MapView.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-20.
//

import SwiftUI
import SpriteKit

struct MapView: View {
    @Binding var showSideMenu: Bool
    
    @State private var mapScene: MapScene? = nil
    @State var selectedRoute: String = "Taiwan"
    
    @State private var selectedHours = 0
    @State private var selectedMinutes = 0
    @State private var selectedSeconds = 0
    @State private var isTimePickerShown = false
    @State private var isNavigatingToTimer = false
    @State private var showAlert = false
    let lightGreen = Color(UIColor(red: 0, green: 0.8, blue: 0.35, alpha: 0.8))

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button(action: {
                        self.showSideMenu.toggle()
                    }) {
                        Image(systemName: "list.bullet")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 24)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
                
                SpriteView(scene: mapScene ?? SKScene())
                    .ignoresSafeArea()
                    .frame(width: 400, height: 300) // Set the size of the map view
                    .gesture(MagnificationGesture().onChanged { scale in
                        // Handle zooming in and out
                        
                        mapScene?.scaleBackground(scale: scale)
                        
                    })
                    .padding(.vertical, 30)
                                
                Text("Set Focus Session Time")
                    .padding(.horizontal)
                    .font(Font.custom("Noteworthy", size: 26))
                    .padding(.bottom, -15)
                                
                HStack {
                    Spacer()
                    
                    Text("\(selectedHours)h \(selectedMinutes)m \(selectedSeconds)s")
                        .font(Font.custom("Noteworthy", size: 26))
                        .padding(.horizontal)
                    
                    
                    
                    Button(action: {
                        withAnimation {
                            self.isTimePickerShown.toggle()
                        }
                    }) {
                        Image(systemName: isTimePickerShown ? "chevron.down.circle" : "chevron.right.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                            .tint(.green)
                    }
                }

                .padding()
                
                if isTimePickerShown {
                    TimePickerView(selectedHours: $selectedHours, selectedMinutes: $selectedMinutes, selectedSeconds: $selectedSeconds)
                        .transition(.opacity)
                }
                
                Spacer()
                
                Button("Start") {
                    print("select route: ", selectedRoute)
                    if selectedHours == 0 && selectedMinutes == 0 && selectedSeconds == 0 {
                        showAlert = true
                    } else {
                        isNavigatingToTimer = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.bottom)
                .tint(lightGreen)
                .alert("Invalid Focus Time", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Please set a focus time greater than 0 second.")
                }
            }
            .navigationDestination(isPresented: $isNavigatingToTimer) {
                TimerView(
                    routeName: selectedRoute,
                    totalTime: TimeInterval((selectedHours * 3600) + (selectedMinutes * 60) + selectedSeconds)
                )
            }
        }
        .onAppear {
            // Initialize the MapScene instance
            selectedHours = 0
            selectedMinutes = 0
            selectedSeconds = 0
            isNavigatingToTimer = false
            
            mapScene = MapScene(selectedRoute: $selectedRoute)
        }
    }
}

#Preview {
    MapView(showSideMenu: .constant(true))
}
