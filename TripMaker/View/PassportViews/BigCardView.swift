//
//  BigCardView.swift
//  TripMaker
//
//  Created by Megan Lin on 4/3/24.
//

import SwiftUI

// ref: https://github.com/MyNameIsBond/customLists/tree/main/customList
struct BigCardView: View {
    
    @State var location: String = "Taiwan"
    @State var image: Image?
    @State var locationDetail: Location?
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                imageFromString(locationDetail?.realPicture ?? "")?
                    .resizable()
                    .frame(height: 160)
                    .frame(maxHeight: .infinity)
                    .cornerRadius(10)
                    
                Spacer()
                VStack(alignment: .leading) {
                    
                    Spacer()
                    Text(locationDetail?.name ?? "")
                        .font(.custom("Noteworthy", size: 22))
                        .foregroundColor(Color.black)
                    
                    HStack {
                        blurTags(tags: locationDetail?.tagsArray ?? [])
                        Spacer()
                    }
                    
                    Spacer()
                    //HStack {
                    //    Stars(star: 4)
                    //        .matchedGeometryEffect(id: "stars", in: namespace)
                    //}
                }
                Spacer()
                VStack {
                    Spacer()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                let db = DBManager.shared
                do {
                    self.locationDetail = try db.fetchLocationDetails(name: location)
                } catch {
                    print("Passport View Database operation failed: \(error)")
                }
            }
        }
    }
}

/*
#Preview {
    BigCardView(p: ListData(title: "LazyHGrid in SwiftUI (part 1/3)", postType: ["iOS","SwiftUI", "Xcode"], date: "05 Jun", Image: "LazyGrid", percentage: 0.30, stars: 5))
}
*/
