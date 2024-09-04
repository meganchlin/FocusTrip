//
//  dataModel.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-17.
//

import UIKit
import Foundation
import SQLite
import Combine

class DBManager {
    
    static let shared = DBManager()
    private(set) var isDatabaseReady = false

    var db: Connection?
    private var iCloudURL: URL?

    let routeTable = RouteTable()
    let locationTable = LocationTable()
    let tagTable = TagTable()
    let rewardTable = RewardTable()
    let focusSessionTable = FocusSessionTable()
    let locationVisitedTable = LocationVisitedTable()
    let userProfileTable = UserProfileTable()
    let userRouteTable = UserRouteTable()
    let userRewardTable = UserRewardTable()

    private init() {
        Task {
            await setupDatabase()
            fetchInfoFromApi()
        }
    }
    
    /* Asynchronously sets up the database by
     either connecting to the existing database or creating a new one.
     */
    func setupDatabase() async {
        let fileManager = FileManager.default
        guard let cloudURL = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
            print("Unable to access iCloud Account")
            return
        }
        let dbURL = cloudURL.appendingPathComponent("db.sqlite3")
        self.iCloudURL = dbURL

        if !fileManager.fileExists(atPath: dbURL.path) {
            do {
                try await initializeDatabase(at: dbURL)
                try await insertInitialData()
            } catch {
                print("Error initializing database with initial data: \(error)")
            }
        } else {
            // Connect to existing database if it exists
            connectToExistingDatabase(at: dbURL)
        }

        isDatabaseReady = true
        print("Database is ready for transactions.")
        
        // Debug purpose
//        inspectAllTables()
    }
    
    // Creates a new database at the specified URL and sets up tables
    private func initializeDatabase(at url: URL) async throws {
        db = try Connection(url.path)
        try createTables()
        print("Initialize database...")
    }
    
    // Connects to an existing database at the specified URL
    private func connectToExistingDatabase(at url: URL) {
        do {
            db = try Connection(url.path)
            print("Connected to existing database.")
        } catch {
            print("Failed to connect to existing database: \(error)")
        }
    }
    
    // Creates tables in the database according to the schema defined in Tables.swift
    private func createTables() throws {
        try db?.run(routeTable.table.create(ifNotExists: true) { t in
            t.column(routeTable.name, primaryKey: true)
            t.column(routeTable.mapPicture)
        })

        try db?.run(locationTable.table.create(ifNotExists: true) { t in
            t.column(locationTable.index)
            t.column(locationTable.route)
            t.column(locationTable.name, primaryKey: true)
            t.column(locationTable.realPicture)
            t.column(locationTable.description)
            t.column(locationTable.isLocked)
            t.foreignKey(locationTable.route, references: routeTable.table, routeTable.name, delete: .cascade)
        })

        try db?.run(tagTable.table.create(ifNotExists: true) { t in
            t.column(tagTable.location)
            t.column(tagTable.tag, primaryKey: true)
            t.foreignKey(tagTable.location, references: locationTable.table, locationTable.name, delete: .cascade)
        })

        try db?.run(rewardTable.table.create(ifNotExists: true) { t in
            t.column(rewardTable.name, primaryKey: true)
            t.column(rewardTable.picture)
            t.column(rewardTable.isClaimed)
        })
        
        try db?.run(userProfileTable.table.create(ifNotExists: true) { t in
            t.column(userProfileTable.userID, primaryKey: true)
            t.column(userProfileTable.username)
            t.column(userProfileTable.image)
            t.column(userProfileTable.dayTotalTime)
            t.column(userProfileTable.weekTotalTime)
            t.column(userProfileTable.monthTotalTime)
            t.column(userProfileTable.yearTotalTime)
        })
        
        try db?.run(userRouteTable.table.create(ifNotExists: true) { t in
            t.column(userRouteTable.userID)
            t.column(userRouteTable.route)
            t.unique(userRouteTable.userID, userRouteTable.route)
            
            t.foreignKey(userRouteTable.userID, references: userProfileTable.table, userProfileTable.userID, delete: .cascade)
            t.foreignKey(userRouteTable.route, references: routeTable.table, routeTable.name, delete: .cascade)
        })
        
        try db?.run(userRewardTable.table.create(ifNotExists: true) { t in
            t.column(userRewardTable.userID)
            t.column(userRewardTable.reward)
            t.unique(userRewardTable.userID, userRewardTable.reward)
            
            t.foreignKey(userRewardTable.userID, references: userProfileTable.table, userProfileTable.userID, delete: .cascade)
            t.foreignKey(userRewardTable.reward, references: rewardTable.table, rewardTable.name, delete: .cascade)
        })
        
        try db?.run(focusSessionTable.table.create(ifNotExists: true) { t in
            t.column(focusSessionTable.focusSessionID, primaryKey: true)
            t.column(focusSessionTable.userID)
            t.column(focusSessionTable.startTime)
            t.column(focusSessionTable.endTime)
            t.foreignKey(focusSessionTable.userID, references: userProfileTable.table, userProfileTable.userID, delete: .cascade)
        })
        
        try db?.run(locationVisitedTable.table.create(ifNotExists: true) { t in
            t.column(locationVisitedTable.focusSessionID)
            t.column(locationVisitedTable.location)
            t.unique(locationVisitedTable.focusSessionID, locationVisitedTable.location)
            
            t.foreignKey(locationVisitedTable.focusSessionID, references: focusSessionTable.table, focusSessionTable.focusSessionID, delete: .cascade)
            t.foreignKey(locationVisitedTable.location, references: locationTable.table, locationTable.name, delete: .cascade)
        })
    }
 
    // Inserts initial data into the database once it's been created
    private func insertInitialData() async throws {
        // Load initial images
        let images = try loadInitialImages()
        
        // Convert images to strings
        let imageStrings = images.map { stringFromImage($0) }
        
        // Insert map routes
        try insertMapRoutes(withImageStrings: Array(imageStrings[0...2]))
        
        // Insert locations for routes
        try insertLocationsForRoutes()
        
        // Insert tags for locations
        try insertTagsForLocations()
        
        // Create user profile and save user ID
        let userID = try createUserProfile(username: UserPreferences.userName, image: imageStrings[3])
        UserPreferences.userID = userID
        print("User ID is \(String(describing: UserPreferences.userID))")
        
        // Insert rewards
        try insertRewards(withImageStrings: Array(imageStrings[4...8]))
        
        // Insert focus sessions
        try insertFocusSessions(forUserID: userID)
    }
    
    private func loadInitialImages() throws -> [UIImage] {
        let imageNames = ["Taiwan-route.jpg", "South Korea-route.jpg", "Canada-route.jpg", "profilePic.jpg", "reward.png", "reward1.png", "reward2.png", "reward3.png", "reward4.png"]
        var images = [UIImage]()
        
        for imageName in imageNames {
            if let image = UIImage(named: imageName) {
                images.append(image)
            } else {
                throw NSError(domain: "com.TripMaker.app", code: 100, userInfo: [NSLocalizedDescriptionKey: "Failed to load image: \(imageName)"])
            }
        }
        
        return images
    }
    
    
    private func insertMapRoutes(withImageStrings imageStrings: [String]) throws {
        try addRoute(name: "Taiwan", mapPicture: imageStrings[0])
        try addRoute(name: "South Korea", mapPicture: imageStrings[1])
        try addRoute(name: "Canada", mapPicture: imageStrings[2])
    }
    
    private func insertLocationsForRoutes() throws {
        let taiwanLocations = [
            ("Bangka Lungshan Temple", true),
            ("National Taichung Theater", true),
            ("Jiufen", true),
            ("Taipei 101", true),
            ("Formosa Boulevard metro station", true),
            ("Fo Guang Shan Buddha Museum", true),
            ("Yehliu", true),
            ("Chiang Kai-shek Memorial Hall", true)
        ]
        
        for (index, location) in taiwanLocations.enumerated() {
            try addLocationToRoute(index: index + 1, routeName: "Taiwan", name: location.0, realPicture: "", description: "", isLocked: location.1)
        }
        
        let koreaLocations = [
            ("Gyeongbokgung Palace", true),
            ("Myeong-dong", true),
            ("N Seoul Tower", true),
            ("Bukchon Hanok Village", true),
            ("Cheonggyecheon", true),
            ("Haedong Yonggungsa", true),
            ("Gamcheon Culture Village", true)
        ]
        
        for (index, location) in koreaLocations.enumerated() {
            try addLocationToRoute(index: index + 1, routeName: "South Korea", name: location.0, realPicture: "", description: "", isLocked: location.1)
        }
        
        let canadaLocations = [
            ("Niagara Falls", true),
            ("Notre-Dame Basilica", true),
            ("Old Quebec", true),
            ("Butchart Gardens", true),
            ("CN Tower", true),
            ("Granville Island", true),
            ("Old Montreal", true),
            ("Canadian Parliament Buildings", true),
            ("Capilano Suspension Bridge Park", true)
        ]
        
        for (index, location) in canadaLocations.enumerated() {
            try addLocationToRoute(index: index + 1, routeName: "Canada", name: location.0, realPicture: "", description: "", isLocked: location.1)
        }
    }
    
    private func insertTagsForLocations() throws {
        let tagsForLocations = [
            ("Bangka Lungshan Temple", ["#ReligiousSite", "#CulturalHeritage"]),
            ("National Taichung Theater", ["#ArchitecturalWonder", "#ArtandCulture"]),
            ("Jiufen", ["#OldStreet", "#HistoricalSite"]),
            ("Taipei 101", ["#EngineeringMarvel", "#CulturalHub"]),
            ("Formosa Boulevard metro station", ["#DomeofLight", "#ArtInstallation"]),
            ("Fo Guang Shan Buddha Museum", ["#Buddhism", "#SpiritualJourney"]),
            ("Yehliu", ["#Queen'sHead", "#NaturalWonder"]),
            ("Chiang Kai-shek Memorial Hall", ["#Monument", "#NationalPride"]),

            ("Gyeongbokgung Palace", ["#KoreanCulture", "#RoyalResidence"]),
            ("Myeong-dong", ["#ShoppingDistrict", "#StreetFood"]),
            ("N Seoul Tower", ["#ObservationTower", "#SeoulSkyline"]),
            ("Bukchon Hanok Village", ["#HanokArchitecture", "#TraditionalVillage"]),
            ("Cheonggyecheon", ["#SeoulStream", "#UrbanRenewal"]),
            ("Haedong Yonggungsa", ["#SeasideTemple", "#BusanLandmark"]),
            ("Gamcheon Culture Village", ["#ColorfulVillage", "#StreetArt"]),
            
            ("Niagara Falls", ["#ScenicViews", "#Adventure"]),
            ("Notre-Dame Basilica", ["#CatholicChurch", "#GothicArchitecture"]),
            ("Old Quebec", ["#CobblestoneStreets", "#EuropeanCharm"]),
            ("Butchart Gardens", ["#Botanical", "#Horticulture"]),
            ("CN Tower", ["#Skyscraper", "#ObservationDeck"]),
            ("Granville Island", ["#Market", "#Art", "#Culture"]),
            ("Old Montreal", ["#Heritage", "#Architecture"]),
            ("Canadian Parliament Buildings", ["#NationalSymbol", "#Monuments"]),
            ("Capilano Suspension Bridge Park", ["#Nature", "#HikingTrails"])
        ]
        
        for (location, tags) in tagsForLocations {
            for tag in tags {
                try addTagToLocation(name: location, tag: tag)
            }
        }
    }
    
    private func insertRewards(withImageStrings imageStrings: [String]) throws {
        let rewardNames = ["1st Reward", "2nd Reward", "3rd Reward", "4th Reward", "5th Reward"]
        for (index, name) in rewardNames.enumerated() {
            try addReward(name: name, picture: imageStrings[index])
        }
    }
    
    private func insertFocusSessions(forUserID userID: UUID) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDate = dateFormatter.string(from: Date())
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // Focus one more seconds will claim a new reward
        let sessionTimes = [
            ("2024-01-01 03:00:00", "2024-01-01 09:35:00"),
            ("2024-01-05 00:00:00", "2024-01-05 22:35:00"),
            ("2024-01-11 00:00:00", "2024-01-11 14:20:00"),
//            ("2024-01-15 01:00:00", "2024-01-15 23:50:00"),
//            ("2024-04-01 10:15:00", "2024-04-01 12:45:00"),
//            ("2024-04-01 14:00:00", "2024-04-01 15:00:00"),
            ("2024-04-02 11:00:00", "2024-04-02 11:26:32"),
            ("2024-04-03 16:34:00", "2024-04-03 17:00:00"),
            ("2024-03-28 10:15:00", "2024-03-28 12:45:00"),
            ("\(todayDate) 00:00:00", "\(todayDate) 01:00:00"),
            ("\(todayDate) 02:00:00", "\(todayDate) 02:35:00"),
            ("\(todayDate) 11:00:00", "\(todayDate) 11:50:00"),
            ("\(todayDate) 16:00:00", "\(todayDate) 16:42:27")
        ]
        
        for (start, end) in sessionTimes {
            if let startTime = dateFormatter.date(from: start),
               let endTime = dateFormatter.date(from: end) {
                let duration = endTime.timeIntervalSince(startTime)
                let _ = try createFocusSession(userID: userID, startTime: startTime, duration: duration)
            }
        }
    }
    
    func fetchInfoFromApi() {
        let url = urlTask()
        //var locations: [String] = []
        Task {
            do {
                let locations = try await fetchAllLocationsInOrder(routeName: "Taiwan")
                print("try to fetch location images")
                for location in locations {
                    url.fetchLocationDescription(for: location)
                    url.fetchLocationPicture(route: "Taiwan", for: location)
                }
            } catch {
                print("error fetching locations for Taiwan")
            }
            
            do {
                let locations = try await fetchAllLocationsInOrder(routeName: "South Korea")
                print("try to fetch location descriptions")
                for location in locations {
                    url.fetchLocationDescription(for: location)
                    url.fetchLocationPicture(route: "South Korea", for: location)
                }
            } catch {
                print("error fetching locations for South Korea")
            }
            
            do {
                let locations = try await fetchAllLocationsInOrder(routeName: "Canada")
                print("try to fetch location descriptions")
                for location in locations {
                    url.fetchLocationDescription(for: location)
                    url.fetchLocationPicture(route: "Canada", for: location)
                }
            } catch {
                print("error fetching locations for Canada")
            }
        }
        
    }
}
