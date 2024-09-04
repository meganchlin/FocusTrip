//
//  UserPreferences.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-04-16.
//

import Foundation

struct UserPreferences {
    // Key used to store the user ID in UserDefaults.
    private static let userIDKey = "userIDKey"
    
    // A flag to indicate when the user profile needs to be refreshed from the database.
    private static var needsRefresh: Bool = true
    
    // Computed property to get and set the user ID. It uses UserDefaults for storage.
    static var userID: UUID? {
        get {
            // Retrieve the user ID string from UserDefaults and convert it to UUID.
            if let idString = UserDefaults.standard.string(forKey: userIDKey), let id = UUID(uuidString: idString) {
                return id
            }
            return nil
        }
        set {
            if let newValue = newValue {
                // Store the UUID string in UserDefaults or remove it if newValue is nil.
                UserDefaults.standard.set(newValue.uuidString, forKey: userIDKey)
            } else {
                UserDefaults.standard.removeObject(forKey: userIDKey)
            }
        }
    }
    
    // Computed property to access the user's profile information from the database.
    static var userProfile: UserProfile? {
        get {
            guard let userID = userID else {
                print("User ID not found.")
                return nil
            }
            
            // Check if the database is ready, otherwise return nil.
            guard DBManager.shared.isDatabaseReady else {
                print("Database is not ready. Still setting it up...")
                return nil
            }
            
            do {
                // Try fetching the user profile using the user ID.
                return try DBManager.shared.fetchUserProfile(userID: userID)
            } catch {
                print("Error fetching user profile: \(error)")
                return nil
            }
        }
    }
    
    // Method to invalidate the cache, requiring a refresh of the user profile on next access.
    static func invalidateUserProfileCache() {
        needsRefresh = true
        print("User profile cache has been invalidated.")
    }
    
    // Computed property to get and set the user's name. It fetches the name from the userProfile and allows updating it.
    static var userName: String {
        get {
            // Return the username from the user profile or a default value if not found.
            userProfile?.username ?? "Snow White"
        }
        set {
            guard let userID = userID else { return }
            do {
                // Attempt to update the username in the database.
                try DBManager.shared.updateUsername(userID: userID, newUsername: newValue)
                
                // Trigger a fetch to update the local user profile cache after modifying the database.
                let updatedProfile = userProfile
                print("Updated profile for: \(String(describing: updatedProfile?.username))")
            } catch {
                print("Error updating username in database: \(error)")
            }
        }
    }
}
