# TripMaker

TripMaker is a dynamic productivity app that enhances focus and motivation through the thrill of virtual travel. Users set a focus timer and advance through global locations, gamifying productivity with immersive travel experiences. Ideal for students, professionals, or anyone looking to boost concentration while exploring the world, TripMaker combines work with pleasure, keeping users engaged, motivated and informed as they achieve their goals. This app promises an enjoyable and educational way to stay focused and meet objectives.

## Setup and Configuration

1. **Apple ID**: Ensure you are logged in with your Apple ID in the simulator to utilize iCloud services.

2. **Xcode Configuration**:
   - Open `TripMaker.xcodeproj` in Xcode.
   - Go to the "Signing & Capabilities" tab.
   - Confirm "Automatically manage signing" is enabled.
   - Select your development team from the drop-down menu.
   - Check the `Bundle Identifier` is correct.
   - Under "iCloud," ensure services are enabled and containers are correctly set.

3. **Database Initialization**: The `DBManager` class handles the database setup automatically when you launch the app for the first time.


## iCloud Integration

When running TripMaker in a simulator logged in with an Apple ID, the following iCloud features are available:

- **iCloud Drive Sync**: After building and running the project, a `MyDocs` directory is created on your iCloud Drive. This directory includes a file named `db.sqlite3`.
- **Accessing Database on iCloud**: You can visit [icloud.com](https://www.icloud.com/) and log in with the same Apple ID used in the simulator. Once logged in, you can access the `MyDocs` directory in iCloud Drive to find the `db.sqlite3` file. This allows you to see your database synced across devices.

**Important**: To open and view the `.sqlite3` file, you need to download the `DB Browser for SQLite` application from [https://sqlitebrowser.org](https://sqlitebrowser.org), which is available for various operating systems. This tool will allow you to open and interact with the SQLite database.


## Key Features

- **Profile Customization**: Personalize your profile with a username and a picture.

- **Map Interactions**: Discover new places through an interactive map experience.

- **Route and Locations Discovery**: Unlock and explore various routes and their associated locations.

- **Focus Sessions**: Improve concentration with dedicated focus sessions. Set the duration using a simple time picker, and select your virtual travel destination by tapping a location on the map. This session helps you progress through routes and unlock new locations.

- **Timer Interface in Focus Sessions**:
    - **Dynamic Countdown**: Once a focus session starts, a live countdown timer tracks the remaining time, helping you stay aware and focused.
    - **Lottie Animation**: A Lottie-powered animated figure walks along the route on the map, visually representing your progress. The movement of the figure correlates with the session's duration, advancing from the start point of the route to your current position based on how long you have been focusing.
    - **Visual Progress Indicator**: The route map displayed during the focus session illuminates as you progress, with a colorful path indicating how much of the route you have completed. This path extends in real-time.
    
- **Stat Tracking**: Visualize your focus time with detailed statistics that enhance your motivation. This feature records cumulative focus durations and displays them graphically, allowing you to track your progress over days, weeks, or months.

- **Reward System**: Earn rewards by achieving focus time milestones and exploring locations. This system incentivizes consistent effort with milestones that reward significant achievements:
    - **1 Hour**: Unlocks the "1st Reward"
    - **10 Hours**: Unlocks the "2nd Reward"
    - **20 Hours**: Unlocks the "3rd Reward"
    - **50 Hours**: Unlocks the "4th Reward"
    - **200 Hours**: Unlocks the "5th Reward"

- **Achievement Tracking**: Achievements are marked by claiming rewards and unlocking new locations through focus sessions. (The minimum length of time required to unlock a new location varies depending on the indicated level.)
    - **Taiwan**: 30min
    - **South Korea**: 60min
    - **Canada**: 120min
    

- **SpriteKit Integration**: Leverage SpriteKit within a SwiftUI framework to create dynamic, interactive map scenes. This integration enriches the user interface by facilitating smooth animations and transitions, enhancing the overall user experience by making the virtual journey visually appealing and engaging.

### User Preferences and Profile Management <br>
  - When a user logs in or updates their profile, `userID` is set, which stores the new ID in `UserDefaults`. <br>
  - Accessing `userProfile` checks the database readiness and fetches or refreshes the profile as necessary. <br>
  - `userName` allows easy access and updating of the user's name directly, with changes reflected in the database and local cache. <br>
  - This setup ensures that the user's profile is efficiently managed and synchronized across the application, with changes persisted between sessions through UserDefaults.

### External APIs and Services 
- **Unsplash API**: Used in the function `fetchLocationPicture(route, for)` which retrieves images for locations to enhance the virtual travel experience. 
- **Wikipedia API**: Used in the function `fetchLocationDescription(for)` which provides descriptions for landmarks, contributing to the educational aspect of the app.

### Third-Party Libraries
- **SQLite.swift 0.15.0**: A Swift framework for interacting with the SQLite database, simplifying SQL operations in Swift.

- **Lottie 4.4.1** <br>
    (1) A library for iOS that parses Adobe After Effects animations exported as json with Bodymovin and renders them natively on mobile.<br>
    (2) To enhance the UI with complex animations, making the user experience more engaging.

### iCloud Integration
- **iCloud Documents** <br>
    (1) Utilizes iCloud's document storage capabilities for data backup and synchronization across devices. <br>
    (2) Leverages `NSUbiquitousKeyValueStore` for seamless iCloud integration with the app's document- based data model.
    
## Function List
### Database Management Functions

1. **Initialization and Setup**
    - `setupDatabase()`: Initializes and connects to the SQLite database. It checks for an existing database at the iCloud-specified path or creates a new one if none exists, then populates it with initial data.
    - `createTables()`: Creates the necessary tables in the database if they do not already exist. This includes tables for routes, locations, tags, rewards, user profiles, user routes, focus sessions, visited locations, and user rewards.
    - `insertInitialData()`: Populates the database with initial data including routes, locations, tags, and rewards. This function is a high-level orchestrator that calls other functions to handle specific types of data insertion.

2. **Data Manipulation**
   - `addRoute(name, mapPicture)`: Adds new travel routes.
   - `addLocationToRoute(index:routeName:name:realPicture:description:isLocked:)`: Adds new locations to specified routes.
   - `addTagToLocation(name:tag)`: Associates tags with locations.
   - `addReward(name:picture,isClaimed)`: Adds rewards into the database.
   - `createUserProfile(username, image)`: Creates a new user profile with a unique identifier.
   - `createFocusSession(userID, startTime, duration)`: Registers a new focus session with start time and duration.
   - `updateVisitedLocations(sessionID, visitedLocations)`: Updates locations visited during a specific focus session.
   - `claimReward(userID, rewardName)`: Marks rewards as claimed by the user.

3. **Data Retrieval**
   - `fetchRouteDetails(route:)`: Retrieves complete details for a specified route.
   - `fetchLocationsForRoute(routeName)`: Gets all locations for a given route.
   - `fetchAllLocationsInOrder(routeName)`: Retrieves all locations in sequence from a route for ordered display.
   - `fetchReward(by)`: Fetches specific reward details using the reward's name.
   - `fetchUserProfile(userID)`: Gathers complete profile details for a user including linked routes, focus sessions, and claimed rewards.
   - `fetchFocusSessionsForUser(userID)`: Retrieves all focus session identifiers linked to a user.
   - `fetchFocusSessionDetails(sessionID)`: Obtains details for a specific focus session.

4. **Data Updates**
   - `updateReward(name, newName, newPicture:isClaimed)`: Modifies details of existing rewards.
   - `updateLocation(name, newName, newRealPicture, newDescription, newIsLocked)`: Changes attributes of an existing location.
   - `updateUserProfile(userID, newUsername, newImage)`: Updates user profile information.
   - `updateUserStats(userID, focusTime)`: Refreshes user statistics with new focus session time and potentially triggers reward claims based on total focus time.
   

## Operating Instructions

Upon initial setup, the database is pre-populated with several focus sessions, automatically claiming three rewards based on these sessions. Starting any new focus session—even for just one second—will cumulatively bring the total focus time to 50 hours, thereby triggering an additional reward.

### Getting Started
The map view is the home base, showcasing your active route. Utilize the side menu for effortless navigation through the app to access map, stats, profile, and travel passport.

### Profile Management
You can edit your profile to update your picture or username at any time. Ensure you save your changes to keep your profile up to date.

### Setting Up Focus Sessions
In the MapView, establish a focus session using the intuitive time picker, and select your next destination by tapping a pin on the map:

- **Selecting a Destination**: Click on any pin that represents a location. Once a pin is selected, a 'Select' button will appear. Pressing this will confirm your destination and initiate the setup for a focus session.
- **Time Selection**: Adjust the session duration to your preference (hours, minutes, seconds) using the time picker. This determines how long you will focus and subsequently, how much virtual travel progress you'll make.

### Focus Session Commitment
Once a focus session starts, an at most 10-second grace period begins during which you can opt to cancel:

- **Cancelation Period**: Immediately after a session starts, a 'Cancel' button appears for 10 seconds. Pressing this button will halt the session and return you to the MapView.
- **Commitment**: If the 10-second window passes without cancellation, the session locks in, and you must complete the set duration. The timer must reach zero before you can leave the session.
- **Ending a Session**: Upon completion of the focus session, a 'Back' button will appear in the navigation bar. Clicking this will navigate you back to the MapView, allowing you to set another session or explore other features.

This system is designed to encourage commitment to focusing while also allowing a brief moment for reconsideration, ensuring that users are confident in their session settings before proceeding. 

### Exploring Routes and Locations

The Passport View acts as your portal to exploring different routes, enhancing geographical and cultural education:

- **Passport View**: Displays all available routes. If no focus sessions have been initiated, routes will show but no specific locations will be accessible.
- **Route Selection**: Upon selecting a route, if no locations have been unlocked via focus sessions, no specific locations will be listed.
- **Unlocked Locations**: If locations within a route are unlocked (e.g., "Taipei 101" in the "Taiwan" route), selecting "Taiwan" in the Passport View will list "Taipei 101" as an accessible location. This approach not only enhances user engagement but also ensures an educational and informed way to keep users focused and motivated.

### Detailed Location View
Clicking on an unlocked location provides:
- **Description**: A detailed description sourced from Wikipedia, offering educational content about the location.
- **Imagery**: A representative image sourced from Unsplash, enhancing the visual experience of the virtual travel.

## Troubleshooting

- **Log into iCloud account in the simulator**: If you're unable to log into your iCloud account in the simulator, navigate to [icloud.com](https://www.icloud.com) and agree to the Terms & Conditions (T&C) there.
- **iCloud Sync**: For synchronization problems, check the Apple ID settings and iCloud configuration in Xcode.

