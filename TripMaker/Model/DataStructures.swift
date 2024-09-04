//
//  DataStructures.swift
//  TripMaker
//
//  Created by Megan Lin on 3/21/24.
//

import Foundation

struct Route {
    let name: String // Primary key
    let locationNames: [String] // Array of Location names
    let mapPicture: String
}

struct Location {
    let index: Int
    let name: String // Primary key and unique
    let realPicture: String
    var tagsArray: [String]
    let description: String
    let isLocked: Bool
}

struct Reward: Hashable {
    let name: String // Primary key and unique
    let picture: String
    let isClaimed: Bool
}

struct FocusSession {
    let ID: UUID
    let startTime: Date
    let endTime: Date
    let locationVisited: [String]
}

struct UserProfile {
    let userID: UUID
    let username: String
    let image: String
    let routeArray: [String] // Route names
    let focusSession: [UUID]
    let dayTotalTime: String
    let weekTotalTime: String
    let monthTotalTime: String
    let yearTotalTime: String
    let rewardsArray: [String] // Reward names
}
