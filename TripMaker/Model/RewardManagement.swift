//
//  RewardManagement.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-20.
//

import Foundation
import SQLite

extension DBManager {
    
    /**
    - Description: Adds a new reward to the database with a specified name and picture.
    - Returns: void (Previously returned UUID, now unnecessary as name is the unique identifier)
    */
    func addReward(name: String, picture: String, isClaimed: Bool = false) throws {
        let insert = rewardTable.table.insert(
            rewardTable.name <- name,
            rewardTable.picture <- picture,
            rewardTable.isClaimed <- isClaimed
        )
        try db?.run(insert)
    }
    
    /**
    - Description: Fetches a single reward identified by its name.
    - Returns: A Reward object if found, otherwise nil.
    */
    func fetchReward(by name: String) -> Reward? {
        do {
            let query = rewardTable.table.filter(rewardTable.name == name)
            if let rewardRow = try db?.pluck(query) {
                return Reward(
                    name: rewardRow[rewardTable.name],
                    picture: rewardRow[rewardTable.picture],
                    isClaimed: rewardRow[rewardTable.isClaimed]
                )
            } else {
                print("No reward found with the given name.")
                return nil
            }
        } catch {
            print("Database error: \(error)")
            return nil
        }
    }
    
    /**
    - Description: Retrieves the details of a specific reward by name.
    - Returns: A Reward object containing the details of the reward.
    */
    func fetchRewardDetails(name: String) throws -> Reward {
        let query = rewardTable.table.filter(rewardTable.name == name)
        guard let reward = try db?.pluck(query) else {
            throw NSError(domain: "Reward Not Found", code: 404, userInfo: nil)
        }
        return Reward(
            name: name,
            picture: reward[rewardTable.picture],
            isClaimed: reward[rewardTable.isClaimed]
        )
    }
    
    /**
    - Description: Updates the information of an existing reward identified by name.
    - Returns: void
    */
    func updateReward(name: String, newName: String? = nil, newPicture: String? = nil, isClaimed: Bool? = nil) throws {
        let rewardToUpdate = rewardTable.table.filter(rewardTable.name == name)
        var setters: [SQLite.Setter] = []
        if let newName = newName {
            setters.append(rewardTable.name <- newName)
        }
        if let newPicture = newPicture {
            setters.append(rewardTable.picture <- newPicture)
        }
        if let isClaimed = isClaimed {
            setters.append(rewardTable.isClaimed <- isClaimed)
        }
        try db?.run(rewardToUpdate.update(setters))
    }
    
    /**
    - Description: Allows a user to claim a reward identified by name.
    - Returns: void
    */
    func claimReward(userID: UUID, rewardName: String) throws {
        let insert = userRewardTable.table.insert(
            userRewardTable.userID <- userID,
            userRewardTable.reward <- rewardName
        )
        try db?.run(insert)
        
        try updateReward(name: rewardName, isClaimed: true)
    }
    
    
    func claimRewards(userID: UUID, yearTotal: TimeInterval) throws {
        let secInHour: TimeInterval = 3600

        let claimedRewards = try fetchRewardsForUser(userID: userID)
        
        if yearTotal >= secInHour && !claimedRewards.contains("1st Reward") { // More than 1 hour and not claimed
            try claimReward(userID: userID, rewardName: "1st Reward")
        }
        if yearTotal >= 10 * secInHour && !claimedRewards.contains("2nd Reward") { // More than 10 hours and not claimed
            try claimReward(userID: userID, rewardName: "2nd Reward")
        }
        if yearTotal >= 20 * secInHour && !claimedRewards.contains("3rd Reward") { // More than 20 hours and not claimed
            try claimReward(userID: userID, rewardName: "3rd Reward")
        }
        if yearTotal >= 50 * secInHour && !claimedRewards.contains("4th Reward") { // More than 50 hours and not claimed
            try claimReward(userID: userID, rewardName: "4th Reward")
        }
        if yearTotal >= 200 * secInHour && !claimedRewards.contains("5th Reward") { // More than 200 hours and not claimed
            try claimReward(userID: userID, rewardName: "5th Reward")
        }
    }
    
    /**
    - Description: Fetches all rewards from the database.
    - Returns: An array of Reward objects representing all the rewards.
    */
    func fetchAllRewards() throws -> [Reward] {
        guard let rewards = try db?.prepare(rewardTable.table) else {
            return []
        }
        return rewards.map { Reward(name: $0[rewardTable.name], picture: $0[rewardTable.picture], isClaimed: $0[rewardTable.isClaimed]) }
    }
    
    /**
    - Description: Deletes a reward from the database using its name.
    - Returns: void
    */
    func deleteReward(name: String) throws {
        let rewardToDelete = rewardTable.table.filter(rewardTable.name == name)
        try db?.run(rewardToDelete.delete())
    }
}

