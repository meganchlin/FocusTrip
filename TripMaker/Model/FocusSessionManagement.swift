//
//  FocusSessionManagement.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-20.
//
import Foundation
import SQLite

extension DBManager {

    /**
    - Description: Updates the list of locations visited during a focus session identified by sessionID.
    - Returns: void
    */
    func updateVisitedLocations(sessionID: UUID, visitedLocations: [String]) throws {
        for location in visitedLocations {
            let insert = locationVisitedTable.table.insert(
                locationVisitedTable.focusSessionID <- sessionID,
                locationVisitedTable.location <- location
            )
            try db?.run(insert)
        }
    }
    

    /**
    - Description: Creates a new focus session for a user with a start time and a duration.
    - Returns: A UUID that uniquely identifies the newly created focus session.
    */
    func createFocusSession(userID: UUID, startTime: Date, duration: TimeInterval) throws -> UUID {
        let sessionID = UUID()
        let insert = focusSessionTable.table.insert(
            focusSessionTable.focusSessionID <- sessionID,
            focusSessionTable.userID <- userID,
            focusSessionTable.startTime <- startTime,
            focusSessionTable.endTime <- startTime.addingTimeInterval(duration)
        )
        try db?.run(insert)
        
        // After creating a session, update user stats
        try updateUserStats(userID: userID, focusTime: duration)
        
        return sessionID
    }
    
    
    /**
        - Description: Deletes a focus session for a user with the specified session ID.
        - Returns: void
    */
    func deleteFocusSession(sessionID: UUID) throws {
        let sessionToDelete = focusSessionTable.table.filter(focusSessionTable.focusSessionID == sessionID)
        let delete = sessionToDelete.delete()
        try db?.run(delete)
    }
    
    
    /**
        - Description: Fetches all locations visited during a specific focus session with given sessionID.
        - Returns: An array of locations visited during the focus session. Returns an empty array if no locations are visited or in case of an error.
    */
    func fetchVisitedLocationsForSession(sessionID: UUID) throws -> [String] {
        let locationsQuery = locationVisitedTable.table.filter(locationVisitedTable.focusSessionID == sessionID)
        let visitedLocationsRecords = try db?.prepare(locationsQuery)
        return visitedLocationsRecords?.map { $0[locationVisitedTable.location] } ?? []
    }
    
    
    /**
    - Description: Retrieves the details of a focus session, including the start time, end time, and locations visited, identified by sessionID.
    - Returns: A FocusSession object with the details of the focus session.
    */
    func fetchFocusSessionDetails(sessionID: UUID) throws -> FocusSession {
        let query = focusSessionTable.table.filter(focusSessionTable.focusSessionID == sessionID)
        guard let session = try db?.pluck(query) else {
            throw NSError(domain: "Session Not Found!", code: 404, userInfo: nil)
        }
        
        let visitedLocations = try fetchVisitedLocationsForSession(sessionID: sessionID)
        
        return FocusSession(
            ID: sessionID,
            startTime: session[focusSessionTable.startTime],
            endTime: session[focusSessionTable.endTime],
            locationVisited: visitedLocations
        )
    }
    
    /**
    - Description: Adds a location to a focusSession.
    - Returns: void
    */
    func addLocationToFocusSession(sessionID: UUID, location: String) throws {
        let insert = locationVisitedTable.table.insert(
            locationVisitedTable.focusSessionID <- sessionID,
            locationVisitedTable.location <- location
        )
        try db?.run(insert)
    }
}
    
