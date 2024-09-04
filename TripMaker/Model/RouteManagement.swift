//
//  RouteManagement.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-20.
//

import Foundation
import SQLite

extension DBManager {
    
    /**
    - Description: Adds a new route to the database with a specified map picture.
    */
    func addRoute(name: String, mapPicture: String) throws {
        let insert = routeTable.table.insert(
            routeTable.name <- name,
            routeTable.mapPicture <- mapPicture
        )
        try db?.run(insert)
    }


    /**
    - Description: Retrieves the details of a specific route by route name, including all the locations that belong to the route.
    - Returns: A Route object containing the route name, array of locations, and the map picture
    */
    func fetchRouteDetails(route: String) throws -> Route {
        let query = routeTable.table.filter(routeTable.name == route)
        guard let routeRecord = try db?.pluck(query) else {
            throw NSError(domain: "Route Not Found!", code: 404, userInfo: nil)
        }
        
        let name = routeRecord[routeTable.name]
        let mapPicture = routeRecord[routeTable.mapPicture]
        let locationsQuery = locationTable.table.filter(locationTable.route == route)
        let locationRecords = try db?.prepare(locationsQuery)
        let locations = locationRecords?.map { $0[locationTable.name] } ?? []
        
        return Route(name: name, locationNames: locations, mapPicture: mapPicture)
    }

    
    /**
        - Description:Fetches all routes from the database.
        - Returns: An array of String  representing all routes in the database.
    */
    func fetchAllRoutes() throws -> [String] {
        guard let routes = try db?.prepare(routeTable.table) else {
            return []
        }
        return routes.map { route in
            route[routeTable.name]
        }
    }
    

    /**
    - Description: Deletes a route with given UUID from the database.
    - Returns: void
    */
    func deleteRoute(route: String) throws {
        let route = routeTable.table.filter(routeTable.name == route)
        try db?.run(route.delete())
    }

}
