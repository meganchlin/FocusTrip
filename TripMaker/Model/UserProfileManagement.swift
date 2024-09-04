//
//  UserProfileManagement.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-20.
//

import Foundation
import SQLite

extension DBManager {

    /**
    - Description: Creates a new user profile with a username and profile image.
    - Returns: A UUID that uniquely identifies the newly created user profile.
    */
    func createUserProfile(username: String, image: String) throws -> UUID {
        let userID = UUID()
        let insert = userProfileTable.table.insert(
            userProfileTable.userID <- userID,
            userProfileTable.username <- username,
            userProfileTable.image <- image,
            userProfileTable.dayTotalTime <- "00:00:00",
            userProfileTable.weekTotalTime <- "00:00:00",
            userProfileTable.monthTotalTime <- "00:00:00",
            userProfileTable.yearTotalTime <- "00:00:00"
        )
        try db?.run(insert)
        return userID
    }
    
    
    /**
    - Description: Fetches all route IDs associated with a given user with specified userID.
    - Returns: An array of UUIDs representing the route IDs associated with the user. Returns an empty array if no routes are found or in case of an error.
    */
    func fetchRoutesForUser(userID: UUID) throws -> [String] {
        let joinQuery = userRouteTable.table.join(routeTable.table, on: userRouteTable.route == routeTable.name)
        let filteredQuery = joinQuery.filter(userRouteTable.userID == userID)
        let routes = try db?.prepare(filteredQuery)
        return routes?.map { $0[routeTable.name] } ?? []
    }
    
    
    /**
    - Description: Retrieves all focus session IDs related to a particular user with specified userID.
    - Returns: An array of UUIDs of the focus sessions associated with the user. An empty array is returned if the user has no focus sessions or in case of an error.
    */
    func fetchFocusSessionsForUser(userID: UUID) throws -> [UUID] {
        let query = focusSessionTable.table.filter(focusSessionTable.userID == userID).select(focusSessionTable.focusSessionID)
        let sessions = try db?.prepare(query)
        return sessions?.map { $0[focusSessionTable.focusSessionID] } ?? []
    }
    
    
    /**
    - Description: Obtains all reward IDs claimed by a user with specified userID.
    - Returns: An array of names for the rewards claimed by the user. If the user has not claimed any rewards or in case of an error, an empty array is returned.
    */
    func fetchRewardsForUser(userID: UUID) throws -> [String] {
        let joinQuery = userRewardTable.table.join(rewardTable.table, on: userRewardTable.reward == rewardTable.name)
        let filteredQuery = joinQuery.filter(userRewardTable.userID == userID)
        let rewards = try db?.prepare(filteredQuery)
        return rewards?.map { $0[rewardTable.name] } ?? []
    }
    
    
    /**
    - Description: Fetches a user profile, including routes, focus sessions, and rewards associated with the user identified by userID.
    - Returns: A UserProfile object containing the user's profile details and associated data.
    */
    func fetchUserProfile(userID: UUID) throws -> UserProfile {
        let query = userProfileTable.table.filter(userProfileTable.userID == userID)
        guard let user = try db?.pluck(query) else {
            throw NSError(domain: "User Not Found!", code: 404, userInfo: nil)
        }
        
        let routeNames = try fetchRoutesForUser(userID: userID)
        let focusSessionIDs = try fetchFocusSessionsForUser(userID: userID)
        let rewardNames = try fetchRewardsForUser(userID: userID)
        
        return UserProfile(
            userID: userID,
            username: user[userProfileTable.username],
            image: user[userProfileTable.image],
            routeArray: routeNames,
            focusSession: focusSessionIDs,
            dayTotalTime: user[userProfileTable.dayTotalTime],
            weekTotalTime: user[userProfileTable.weekTotalTime],
            monthTotalTime: user[userProfileTable.monthTotalTime],
            yearTotalTime: user[userProfileTable.yearTotalTime],
            rewardsArray: rewardNames
        )
    }
    
    /**
     - Description: Fetches a user profile by username.
     - Returns: A UserProfile object containing the user's profile details and associated data, or nil if the user is not found.
     */
     func fetchUserProfileByUsername(username: String) throws -> UserProfile? {
         let query = userProfileTable.table.filter(userProfileTable.username == username)
         guard let user = try db?.pluck(query) else {
             throw NSError(domain: "User Not Found!", code: 404, userInfo: nil)
         }

         let userID = user[userProfileTable.userID]
         let routeNames = try fetchRoutesForUser(userID: userID)
         let focusSessionIDs = try fetchFocusSessionsForUser(userID: userID)
         let rewardNames = try fetchRewardsForUser(userID: userID)

         return UserProfile(
             userID: userID,
             username: username,
             image: user[userProfileTable.image],
             routeArray: routeNames,
             focusSession: focusSessionIDs,
             dayTotalTime: user[userProfileTable.dayTotalTime],
             weekTotalTime: user[userProfileTable.weekTotalTime],
             monthTotalTime: user[userProfileTable.monthTotalTime],
             yearTotalTime: user[userProfileTable.yearTotalTime],
             rewardsArray: rewardNames
         )
     }
    
    
    /**
    - Description: Fetches the user's statistics, including the total focus time over days, weeks, months, and years for the user identified by userID.
    - Returns: A tuple containing the user's focus time statistics.
    */
    func fetchUserStats(userID: UUID) throws -> (dayTotalTime: String, weekTotalTime: String, monthTotalTime: String, yearTotalTime: String) {
        let query = userProfileTable.table.filter(userProfileTable.userID == userID)
        guard let user = try db?.pluck(query) else {
            throw NSError(domain: "User Not Found!", code: 404, userInfo: nil)
        }
        return (
            dayTotalTime: user[userProfileTable.dayTotalTime],
            weekTotalTime: user[userProfileTable.weekTotalTime],
            monthTotalTime: user[userProfileTable.monthTotalTime],
            yearTotalTime: user[userProfileTable.yearTotalTime]
        )
    }
    
    
    /**
    - Description: Records a user's trip by associating a user with a route.
    - Returns: void
    */
    func recordUserTrip(userID: UUID, routeName: String) throws {
        let insert = userRouteTable.table.insert(
            userRouteTable.userID <- userID,
            userRouteTable.route <- routeName
        )
        try db?.run(insert)
    }
    
    
    /**
    - Description: Updates a user's statistics with the new focus time. It increments the day, week, month, and year totals of the user identified by userID.
    - Returns: void
    */
    func updateUserStats(userID: UUID, focusTime: TimeInterval) throws {
        // Function to convert time interval to "HH:mm:ss" format
        func timeString(from interval: TimeInterval) -> String {
            let time = NSInteger(interval)
            let seconds = time % 60
            let minutes = (time / 60) % 60
            let hours = (time / 3600)
            return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
        }
        
        let userProfile = userProfileTable.table.filter(userProfileTable.userID == userID)
        if let user = try db?.pluck(userProfile) {
            let newYearTotalTimeInterval = focusTime + timeInterval(from: user[userProfileTable.yearTotalTime])
            let newYearTotalTime = timeString(from: newYearTotalTimeInterval)
            
            // Update the user profile with the new total times
            let update = userProfile.update(
                userProfileTable.dayTotalTime <- timeString(from: focusTime + timeInterval(from: user[userProfileTable.dayTotalTime])),
                userProfileTable.weekTotalTime <- timeString(from: focusTime + timeInterval(from: user[userProfileTable.weekTotalTime])),
                userProfileTable.monthTotalTime <- timeString(from: focusTime + timeInterval(from: user[userProfileTable.monthTotalTime])),
                userProfileTable.yearTotalTime <- newYearTotalTime
            )
            try db?.run(update)
            
            // Claim rewards based on the year total time
            try claimRewards(userID: userID, yearTotal: newYearTotalTimeInterval)
        }
    }
    
    func timeInterval(from timeString: String) -> TimeInterval {
        let components = timeString.split(separator: ":").compactMap { Int($0) }
        let hours = components.count > 0 ? components[0] : 0
        let minutes = components.count > 1 ? components[1] : 0
        let seconds = components.count > 2 ? components[2] : 0
        return TimeInterval(hours * 3600 + minutes * 60 + seconds)
    }
    
    /**
    - Description: Checks if the username is unique in the database.
    - Returns: Calls the completion handler with true if unique, false otherwise.
    */
    func isUsernameUnique(_ username: String, completion: @escaping (Bool) -> Void) {
        let query = userProfileTable.table.filter(userProfileTable.username == username)
        do {
            let existingUser = try db?.pluck(query)
            completion(existingUser == nil)
        } catch {
            print("Error checking username uniqueness: \(error)")
            completion(false)
        }
    }

    /**
    - Description: Updates the username for a given userID in the database.
    */
    func updateUsername(userID: UUID, newUsername: String) throws {
        let user = userProfileTable.table.filter(userProfileTable.userID == userID)
        let update = user.update(userProfileTable.username <- newUsername)
        try db?.run(update)
    }
    
    /**
     - Description: Updates the user profile including username and image.
     - Throws: An `Error` if the update could not be completed.
     */
    func updateUserProfile(userID: UUID, newUsername: String, newImage: String) throws {
        let userProfile = userProfileTable.table.filter(userProfileTable.userID == userID)
        let update = userProfile.update([
            userProfileTable.username <- newUsername,
            userProfileTable.image <- newImage
        ])
        try db?.run(update)
        print("Updated user profile for userID \(userID). New username: \(newUsername).")
//        print("New pic: \(newImage)")
    }
}
