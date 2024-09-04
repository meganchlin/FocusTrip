//
//  PassportView.swift
//  TripMaker
//
//  Created by Megan Lin on 3/21/24.
//


import SwiftUI

// ref: https://github.com/MyNameIsBond/customLists/tree/main/customList
struct BlurView: UIViewRepresentable {
    
    let style: UIBlurEffect.Style
    
    func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIView,
                      context: UIViewRepresentableContext<BlurView>) {
        
    }
}


struct PassportView: View {
    @Binding var presentSideMenu: Bool
    
    @State var small = true
    @Namespace var namespace
    @State var routes: [String] = []
    @State var isPresented = false
    @State var selectedRoute = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.green.opacity(0.3), Color.yellow.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                Image("passport-background")
                    .resizable()
                    //.scaledToFill()
                    .opacity(0.3)
                    .ignoresSafeArea()

                ScrollView {
                    HStack{
                        Button{
                            presentSideMenu.toggle()
                        } label: {
                            Image(systemName: "list.bullet")
                                .resizable()
                                .frame(width: 28, height: 24)
                                .foregroundColor(.orange)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    VStack {
                        ForEach(routes, id: \.self) { route in
                            Button(action: {
                                self.isPresented = true
                                self.selectedRoute = route
                            }) {
                                SmallCardView(route: route)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .frame(height: 150)
                                .background(BlurView(style: .regular))
                                .cornerRadius(10)
                                .padding(.vertical,6)
                                .padding(.horizontal)
                            }
                            //CardDetector(position: self.position, route: route)
                        }
                        .navigationDestination(isPresented: $isPresented) {
                            RouteView(route: selectedRoute)
                        }
                    }
                    
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            print("passport view")
            DispatchQueue.main.async {
                let db = DBManager.shared
                do {
                    self.routes = try db.fetchAllRoutes()
                    print("")
                } catch {
                    print("Passport View Database operation failed: \(error)")
                }
            }
        }
    }
}



#Preview {
    PassportView(presentSideMenu: .constant(true), routes : ["Taiwan", "Canada"])
}
