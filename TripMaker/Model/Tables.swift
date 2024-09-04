//
//  Tables.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-16.
//

import Foundation
import SQLite

struct RouteTable {
    let table = Table("routes")
    let name = Expression<String>("name") // primary key
    let mapPicture = Expression<String>("mapPicture")
}

struct LocationTable {
    let table = Table("locations")
    let index = Expression<Int>("index")
    let route = Expression<String>("route") // foreign key
    let name = Expression<String>("name") // primary key
    let realPicture = Expression<String>("realPicture")
    let description = Expression<String>("description")
    let isLocked = Expression<Bool>("isLocked")
}

struct TagTable {
    let table = Table("tags")
    let location = Expression<String>("location") // foreign key
    let tag = Expression<String>("tag") // primary key
}

struct RewardTable {
    let table = Table("rewards")
    let name = Expression<String>("name") // primary key
    let picture = Expression<String>("picture")
    let isClaimed = Expression<Bool>("isClaimed")
}

struct FocusSessionTable {
    let table = Table("focusSession")
    let focusSessionID = Expression<UUID>("ID") // primary key
    let userID = Expression<UUID>("userID") // foreign key
    let startTime = Expression<Date>("startTime")
    let endTime = Expression<Date>("endTime")
}

struct LocationVisitedTable {
    let table = Table("locationVisited")
    let focusSessionID = Expression<UUID>("focusSessionID") // foreign key
    let location = Expression<String>("location") // foreign key
}

struct UserProfileTable {
    let table = Table("userProfile")
    let userID = Expression<UUID>("userID") // primary key
    let username = Expression<String>("username")
    let image = Expression<String>("image")
    let dayTotalTime = Expression<String>("dayTotalTime")
    let weekTotalTime = Expression<String>("weekTotalTime")
    let monthTotalTime = Expression<String>("monthTotalTime")
    let yearTotalTime = Expression<String>("yearTotalTime")
}

struct UserRouteTable {
    let table = Table("userRoute")
    let userID = Expression<UUID>("userID") // foreign key
    let route = Expression<String>("route") // foreign key
}

struct UserRewardTable {
    let table = Table("userRewards")
    let userID = Expression<UUID>("userID") // foreign key
    let reward = Expression<String>("reward") // foreign key
}
