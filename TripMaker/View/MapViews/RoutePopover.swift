//
//  RoutePopover.swift
//  TripMaker
//
//  Created by Megan Lin on 3/31/24.
//

import SwiftUI


struct RoutePopover: View {
    var scene: MapScene!
    var node: AnnotationNode!
    
    var route: String
    @State var isSelected = false
    
    var body: some View {
        NavigationView{
            
            VStack (spacing: 5){
                Text(route)
                    .font(.custom("Bradley Hand", size: 22))
                    //.padding(.top, 15)
                
                Spacer()
                
                Image(route + "-map")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .padding(.bottom, 5)
                    //.scaledToFill()

                HStack {
                    Text("Level: ")
                        .font(.custom("Bradley Hand", size: 18))
                    Stars(star: TripConfig.route_level[route] ?? 3)
                }
                
                Spacer()
                
                Button(action: {
                    isSelected = true
                    scene.selectRoute(route: route)
                    
                }, label: {
                    if isSelected {
                        Text("Select")
                            //.padding(.vertical, 10)
                            .frame(width: 100)
                            .background(Color.gray.opacity(0.3))
                    } else {
                        Text("Select")
                            //.padding(.vertical, 10)
                            .frame(width: 100)
                    }
                })
                .padding(.bottom, 25)
                
                Spacer()
            }
            
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            scene.dismissPopover()
                            node.annotationUntapped()
                        }, label: {
                            Label("", systemImage: "xmark.square")
                        })
                    }
                }
        }
    }
}

#Preview {
    RoutePopover(route: "Taiwan")
}
