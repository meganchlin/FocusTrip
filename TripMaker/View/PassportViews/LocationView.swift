//
//  LocationView.swift
//  TripMaker
//
//  Created by Megan Lin on 3/19/24.
//

import SwiftUI

struct LocationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var location: String
    @State var locationDetail: Location?
    
    
    var body: some View {
        VStack{
            imageFromString(locationDetail?.realPicture ?? "")?
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 395, height: 380)
                .cornerRadius(30.0)
                .padding(.top, -100)
                .shadow(radius: 15)
            //.padding(.bottom, 20)
            HStack{
                VStack{
                    HStack {
                        Text(locationDetail?.name ?? "")
                            .font(Font.custom("Noteworthy", size: 30))
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    
                    blurTags(tags: locationDetail?.tagsArray ?? [], size: 16)
                }
                Spacer()
                Image(locationDetail?.name ?? "default")
                    .resizable()
                    .frame(width: 80, height: 80)

            }
            .padding(25)
            Spacer()
            Text(locationDetail?.description ?? "")
                .font(.custom("Palatino", size: 18))
                .padding(.horizontal, 25)
            Spacer()
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
                    self.locationDetail = try db.fetchLocationDetails(name: location)
                } catch {
                    print("Location View Database operation failed: \(error)")
                }
            }
        }
    }
}

#Preview {
    //let modelData = ModelData()
    return LocationView(location: "Taipei 101")
}
