//
//  ProfileView.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-20.
//

import SwiftUI

struct ProfileView: View {
    @Binding var presentSideMenu: Bool
    @State private var editableUsername: String = UserPreferences.userName
    @State private var selectedImageIndex: Int = 0 {
        didSet {
            // Update the editableImage whenever selectedImageIndex changes
            if let imageName = profileImages[safe: selectedImageIndex], let uiImage = UIImage(named: imageName) {
                self.editableImage = Image(uiImage: uiImage)
            }
        }
    }
    @State private var editableImage: Image? = imageFromString(UserPreferences.userProfile?.image ?? "")
    @State private var isEditing: Bool = false
    let lightPurple = Color(UIColor(red: 217/256, green: 159/256, blue: 255/256, alpha: 1))
    
    let brightPink = Color(UIColor(red: 256/256, green: 85/256, blue: 120/256, alpha: 0.8))
    
    // Use a computed property to get the current image name based on the selected index.
    private var currentImageName: String {
        profileImages[selectedImageIndex]
    }
    
    // Update the editableImage whenever the selection changes.
    private var currentEditableImage: Image {
        Image(uiImage: UIImage(named: currentImageName)!)
    }
    
    private let profileImages = ["profilePic", "profilePic1", "profilePic2", "profilePic3"]
    
    private var userProfile: UserProfile? {
        UserPreferences.userProfile
    }
    
    private var userRewards: [Reward] {
        userProfile?.rewardsArray.compactMap { rewardName in
            do {
                return try DBManager.shared.fetchRewardDetails(name: rewardName)
            } catch {
                print("Error fetching reward details for \(rewardName): \(error)")
                return nil
            }
        }.sorted(by: { $0.name < $1.name }) ?? []
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3), Color.pink.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Button(action: {
                            self.presentSideMenu.toggle()
                        }) {
                            Image(systemName: "list.bullet")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 24)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if let userProfile = userProfile {
                        VStack {
                            editableImage?
                                .resizable()
                                 .aspectRatio(contentMode: .fill)
                                 .frame(width: 150, height: 150)
                                 .cornerRadius(75)
                                 .overlay(Circle().stroke(Color.purple.opacity(0.7), lineWidth: 4))
                                 .padding(.top, 20)

                            
                            if isEditing {
                                Picker("Select your profile picture:", selection: $selectedImageIndex) {
                                    ForEach(0..<profileImages.count, id: \.self) { index in
                                        Text(String("Avatar \(index)"))
                                            .tag(index)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding()
                                .onChange(of: selectedImageIndex, initial: false) { self.editableImage = self.currentEditableImage
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            
                                TextField("Username", text: $editableUsername)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                
                                Button("Save Changes") {
                                    saveProfileChanges()
                                }
                                .padding()
                                .background(brightPink)
                                .foregroundColor(Color.white)
                                .clipShape(Capsule())
                                
                            } else {
                                Text(userProfile.username)
                                    .font(.title)
                                    .fontWeight(.bold)
                                Button("Edit Profile") {
                                    self.isEditing = true
                                    self.editableUsername = userProfile.username
                                    self.selectedImageIndex = self.profileImages.firstIndex(of: userProfile.image) ?? 0
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                    } else {
                        Text("Loading profile...")
                            .font(.title)
                    }
                    // Achievements section
                    Text("My Achievements")
                        .font(Font.custom("Noteworthy", size: 28))
                        .padding(.leading)
                    
                    ForEach(userRewards.chunked(into: 3), id: \.self) { rowRewards in
                        HStack {
                            ForEach(rowRewards, id: \.name) { reward in
                                VStack {
                                    imageFromString(reward.picture)?
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 150)
                                                .stroke(.purple.opacity(0.5), lineWidth: 6)
                                        )
                                        .cornerRadius(150)
                                        .padding(.top, 20)
                                        .padding(.bottom, 1)
                                    Text(reward.name)
                                        .font(Font.custom("Optima", size: 14))
                                        .frame(width: 100)
                                }
                            }
                        }
                        .padding(.vertical, -10)
                        
                    }
                    
                    .padding(.leading)
                }
                .padding(.horizontal)
            }
            .onAppear {
                UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(lightPurple
                )
                
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
                
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black.withAlphaComponent(0.8)], for: .normal)
            }
        }
    }
    
    private func saveProfileChanges() {
        guard let userID = UserPreferences.userID, !editableUsername.isEmpty else { return }
        // Get the UIImage from the selected index in the picker.
        if let selectedImage = UIImage(named: profileImages[selectedImageIndex]) {
            // Convert the UIImage to a Data object and then to a base64 encoded string.
            let imageString = stringFromImage(selectedImage)

            // Check if the username is unique only if it has been changed.
            if editableUsername != userProfile?.username {
                DBManager.shared.isUsernameUnique(editableUsername) { isUnique in
                    if isUnique {
                        self.updateUserProfile(userID: userID, newUsername: self.editableUsername, newImage: imageString)
                    } else {
                        print("Username is not unique.")
                    }
                }
            } else {
                // If the username hasn't changed, update the profile with the new image only.
                self.updateUserProfile(userID: userID, newUsername: editableUsername, newImage: imageString)
            }
        }
    }

    private func updateUserProfile(userID: UUID, newUsername: String, newImage: String) {
        do {
            try DBManager.shared.updateUserProfile(userID: userID, newUsername: newUsername, newImage: newImage)
            self.isEditing = false
            // Invalidate the cached user profile and fetch the updated information.
            UserPreferences.invalidateUserProfileCache()
            _ = UserPreferences.userProfile
            print("Profile successfully updated.")
        } catch {
            print("Error updating profile: \(error)")
        }
    }
}


extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    ProfileView(presentSideMenu: .constant(true))
}
