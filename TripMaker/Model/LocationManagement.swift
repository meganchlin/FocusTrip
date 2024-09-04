//
//  LocationManagement.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-20.
//

import Foundation
import SQLite

extension DBManager {
    
    /**
     - Description: Adds a new location to an existing route identified by route name.
     - Returns: The name of the newly added location as it's the primary key.
     */
    func addLocationToRoute(index: Int, routeName: String, name: String, realPicture: String, description: String, isLocked: Bool) throws {
        let insert = locationTable.table.insert(
            locationTable.index <- index,
            locationTable.route <- routeName,
            locationTable.name <- name,
            locationTable.realPicture <- realPicture,
            locationTable.description <- description,
            locationTable.isLocked <- isLocked
        )
        try db?.run(insert)
    }
    
    /**
     - Description: Retrieves all locations associated with a given route name.
     - Returns: An array of Location objects, each representing a location on the route with its associated tags.
     */
    func fetchLocationsForRoute(routeName: String) throws -> [Location] {
        let query = locationTable.table
            .join(tagTable.table, on: locationTable.name == tagTable.location)
            .filter(locationTable.route == routeName)
            .select(locationTable.table[*], tagTable.tag)
        
        var locations: [String: Location] = [:]
        
        for row in try db!.prepare(query) {
            let locationName = row[locationTable.name]
            let tagsQuery = tagTable.table.where(tagTable.location == locationName).select(tagTable.tag)
            let tags = try db?.prepare(tagsQuery).map { $0[tagTable.tag] } ?? []
            
            locations[locationName] = Location(
                index: row[locationTable.index],
                name: locationName,
                realPicture: row[locationTable.realPicture],
                tagsArray: tags,
                description: row[locationTable.description],
                isLocked: row[locationTable.isLocked]
            )
        }
        
        return Array(locations.values)
    }
    
    /**
     - Description: Retrieves all locations associated with a given route name in order.
     - Returns: An array of Location names, each representing a location on the route.
     */
    func fetchAllLocationsInOrder(routeName: String) async throws -> [String] {
        let locationsQuery = locationTable.table
            .select(locationTable.name, locationTable.index)
            .filter(locationTable.route == routeName)
        
        let locationRecords = try db?.prepare(locationsQuery)
        let locations = locationRecords?.compactMap { record in
            return (name: record[locationTable.name], index: record[locationTable.index])
        } ?? []
        
        // Sort the locations by index
        let sortedLocations = locations.sorted(by: { $0.index < $1.index })
        
        // Extract only the names
        let names = sortedLocations.map { $0.name }
        
        return names
    }
    
    /**
     - Description: Retrieves unlocked locations associated with a given route name.
     - Returns: An array of Location names, each representing a location on the route.
     */
    func fetchUnlockedLocations(routeName: String) throws -> [String] {
        let locationsQuery = locationTable.table
            .select(locationTable.name, locationTable.index)
            .filter(locationTable.route == routeName && locationTable.isLocked == false)
        
        let locationRecords = try db?.prepare(locationsQuery)
        let locations = locationRecords?.compactMap { record in
            return (name: record[locationTable.name], index: record[locationTable.index])
        } ?? []
        
        // Sort the locations by index
        let sortedLocations = locations.sorted(by: { $0.index < $1.index })
        
        // Extract only the names
        let names = sortedLocations.map { $0.name }
        
        return names
    }
    
    /**
     - Description: Fetches all tags associated with a specific location by its name.
     - Returns: An array of strings representing the tags associated with the location.
     */
    func fetchTagsForLocation(name: String) throws -> [String] {
        let tagsQuery = tagTable.table.filter(tagTable.location == name).select(tagTable.tag)
        let tagsRecords = try db?.prepare(tagsQuery)
        return tagsRecords?.map { $0[tagTable.tag] } ?? []
    }
    
    /**
     - Description: Updates the picture of an existing location identified by name.
     - Returns: void
     */
    func updateLocatioPicture(name: String, newRealPicture: String) throws {
        let locationToUpdate = locationTable.table.filter(locationTable.name == name)
        try db?.run(locationToUpdate.update(
            locationTable.realPicture <- newRealPicture
        ))
    }
    
    /**
     - Description: Updates the description of an existing location identified by name.
     - Returns: void
     */
    func updateLocatioDescription(name: String, newDescription: String) throws {
        let locationToUpdate = locationTable.table.filter(locationTable.name == name)
        try db?.run(locationToUpdate.update(
            locationTable.description <- newDescription
        ))
    }
    
    /**
     - Description: Updates the details of an existing location identified by name.
     - Returns: void
     */
    func updateLocation(name: String, newName: String, newRealPicture: String, newDescription: String, newIsLocked: Bool) throws {
        let locationToUpdate = locationTable.table.filter(locationTable.name == name)
        try db?.run(locationToUpdate.update(
            locationTable.name <- newName,
            locationTable.realPicture <- newRealPicture,
            locationTable.description <- newDescription,
            locationTable.isLocked <- newIsLocked
        ))
    }
    
    /**
     - Description: Removes an existing location from the database identified by name.
     - Returns: void
     */
    func deleteLocation(name: String) throws {
        let locationToDelete = locationTable.table.filter(locationTable.name == name)
        try db?.run(locationToDelete.delete())
    }
    
    
    /**
    - Description: Fetches a single location's details by location name.
    - Returns: A Location object containing the details of the location.
    */
    func fetchLocationDetails(name: String) throws -> Location {
        let query = locationTable.table.filter(locationTable.name == name)
        
        guard let location = try db?.pluck(query) else {
            throw NSError(domain: "Location Not Found!", code: 404, userInfo: nil)
        }
        
        let tags = try fetchTagsForLocation(name: name)
        
        return Location(
            index: location[locationTable.index],
            name: name,
            realPicture: location[locationTable.realPicture],
            tagsArray: tags,
            description: location[locationTable.description],
            isLocked: location[locationTable.isLocked]
        )
    }
    
    /**
    - Description: Updates the lock status of a specific location identified by location name.
    - Returns: void
    */
    func updateLocationLockStatus(name: String, isLocked: Bool) throws {
        let location = locationTable.table.filter(locationTable.name == name)
        try db?.run(location.update(locationTable.isLocked <- isLocked))
    }
    
    
    /**
    - Description: Adds a new tag to a location. The tag is associated with the location identified by location name.
    - Returns: void
    */
    func addTagToLocation(name: String, tag: String) throws {
        let insert = tagTable.table.insert(
            tagTable.location <- name,
            tagTable.tag <- tag
        )
        try db?.run(insert)
    }

}
