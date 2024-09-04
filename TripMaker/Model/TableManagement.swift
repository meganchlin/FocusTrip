//
//  TableManagement.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-20.
//

import UIKit
import Foundation
import SQLite

extension DBManager {
    
    func deleteAllRoutes() throws {
        try db?.run(routeTable.table.delete())
    }
    
    func deleteAllLocations() throws {
        try db?.run(locationTable.table.delete())
    }

    func deleteAllTags() throws {
        try db?.run(tagTable.table.delete())
    }

    func deleteAllRewards() throws {
        try db?.run(rewardTable.table.delete())
    }

    func deleteAllFocusSessions() throws {
        try db?.run(focusSessionTable.table.delete())
    }

    func deleteAllLocationVisited() throws {
        try db?.run(locationVisitedTable.table.delete())
    }

    func deleteAllUserProfiles() throws {
        try db?.run(userProfileTable.table.delete())
    }

    func deleteAllUserRoutes() throws {
        try db?.run(userRouteTable.table.delete())
    }

    func deleteAllUserRewards() throws {
        try db?.run(userRewardTable.table.delete())
    }
    
    func deleteAllData() {
        do {
            // Start with tables that don't depend on others
            try deleteAllTags()
            try deleteAllLocationVisited()
            try deleteAllUserRewards()
            try deleteAllUserRoutes()
            // Then, tables referenced by foreign keys
            try deleteAllLocations()
            try deleteAllRewards()
            try deleteAllFocusSessions()
            // Finally, tables that are primary sources of foreign keys
            try deleteAllRoutes()
            try deleteAllUserProfiles()
            
            print("All data deleted successfully.")
        } catch {
            print("An error occurred while deleting data: \(error)")
        }
    }
    
    
    func inspectRouteTable() throws {
        let query = routeTable.table

        guard let routes = try db?.prepare(query) else {
            print("No routes found or database preparation failed.")
            return
        }

        for route in routes {
            print("Route ID: \(route[routeTable.name])\n")
//            print("Map Picture: \(route[routeTable.mapPicture])")
        }
    }
    
    func inspectLocationTable() throws {
        let query = locationTable.table
        
        guard let locations = try db?.prepare(query) else {
            print("No locations found or database preparation failed.")
            return
        }
        
        for location in locations {
            print("Location ID: \(location[locationTable.name]), Name: \(location[locationTable.name]), Description: \(location[locationTable.description]), Is Locked: \(location[locationTable.isLocked])\n")
            
            print("Real Picture: \(location[locationTable.realPicture]),")
            
        }
        
    }
    
    func inspectTagTable() throws {
        let query = tagTable.table
        
        guard let tags = try db?.prepare(query) else {
            print("No tags found or database preparation failed.")
            return
        }
        
        for tag in tags {
            print("Tag ID: \(tag[tagTable.tag]), Location ID: \(tag[tagTable.location]), Tag: \(tag[tagTable.tag])")
        }
    }
    
    func inspectRewardTable() throws {
        let query = rewardTable.table
        guard let rewards = try db?.prepare(query) else {
            print("No rewards found or database preparation failed.")
            return
        }
        for reward in rewards {
            print("Reward Name: \(reward[rewardTable.name]), Is Claimed: \(reward[rewardTable.isClaimed])\n")
//            print("Picture: \(reward[rewardTable.picture])\n")
        }
    }
    
    func inspectFocusSessionTable() throws {
        let query = focusSessionTable.table
         
        
        guard let focusSessions = try db?.prepare(query) else {
            print("No focus sessions found or database preparation failed.")
            return
        }
        
        for session in focusSessions {
            print("Focus Session ID: \(session[focusSessionTable.focusSessionID]), User ID: \(session[focusSessionTable.userID]), Start Time: \(session[focusSessionTable.startTime]), End Time: \(session[focusSessionTable.endTime])")
        }
    }
    
    func inspectLocationVisitedTable() throws {
        let query = locationVisitedTable.table

        guard let visitedLocations = try db?.prepare(query) else {
            print("No visited locations found or database preparation failed.")
            return
        }
        
        for visited in visitedLocations {
            print("Focus Session ID: \(visited[locationVisitedTable.focusSessionID]), Location ID: \(visited[locationVisitedTable.location])")
        }
    }
    
    func inspectUserProfileTable() throws {
        let query = userProfileTable.table
         
        guard let userProfiles = try db?.prepare(query) else {
            print("No user profiles found or database preparation failed.")
            return
        }
        
        for userProfile in userProfiles {
            print("User ID: \(userProfile[userProfileTable.userID]), Username: \(userProfile[userProfileTable.username])\n")
//            print("Image: \(userProfile[userProfileTable.image])")
        }
    }
    
    func inspectAllTables() {
        do {
            print("\nInspecting Route Table:")
            try inspectRouteTable()
            
            print("\nInspecting Location Table:")
            try inspectLocationTable()
            
            print("\nInspecting Tag Table:")
            try inspectTagTable()
            
            print("\nInspecting Reward Table:")
            try inspectRewardTable()
            
            print("\nInspecting FocusSession Table:")
            try inspectFocusSessionTable()
            
            print("\nInspecting LocationVisited Table:")
            try inspectLocationVisitedTable()
            
            print("\nInspecting UserProfile Table:")
            try inspectUserProfileTable()
            
        } catch {
            print("An error occurred while inspecting the tables: \(error)")
        }
    }
    
}

