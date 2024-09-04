//
//  SmallCardView.swift
//  TripMaker
//
//  Created by Megan Lin on 3/21/24.
//

import SwiftUI

// ref: https://github.com/MyNameIsBond/customLists/tree/main/customList
struct SmallCardView: View {
    
    @State var route: String = "Taiwan"
    //@State var image: Image?
    @State var routeDetail: Route?
    
    var body: some View {
        GeometryReader { g in
            VStack(alignment: .leading) {
                HStack {
                    Image(route + "-stamp")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(route)
                            .font(.custom("Noteworthy", size: 28))
                            .foregroundColor(Color.black)
                        Spacer()
                        //blurTags(tags: ["SwiftUI"], namespace: namespace)
                        //Spacer()
                        HStack {
                            Text("Level: ")
                                .font(Font.custom("Bradley Hand", size: 20))
                                .foregroundColor(.black)
                            Stars(star: TripConfig.route_level[route] ?? 3)
                        }
                        Spacer()
                    }.padding(.leading)
                    Spacer()
                    
                }
            }
        }
    }
}

/*
 #Preview {
 SmallCardView(routeID: UUID())
 }
 */
