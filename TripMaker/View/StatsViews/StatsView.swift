//
//  StatsView.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-21
//

import SwiftUI
import Combine

struct StatsView: View {
    @Binding var presentSideMenu: Bool
    @State private var timeframeSelection: Int = 0
    @State private var dayStats: [CGFloat] = []
    @State private var weekStats: [CGFloat] = []
    @State private var yearStats: [CGFloat] = []
    let lightGreen = Color(UIColor(red: 0, green: 0.8, blue: 0.35, alpha: 0.6))
    let darkGreen = Color(UIColor(red: 0, green: 0.6, blue: 0.1, alpha: 0.8))

    let dbManager = DBManager.shared
    let username = UserPreferences.userName

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.2), darkGreen.opacity(0.2), darkGreen.opacity(0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Button(action: {
                        self.presentSideMenu.toggle()
                    }) {
                        Image(systemName: "list.bullet")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 24)
                    }
                    .tint(darkGreen)
                    Spacer()
                }
                .padding(.horizontal)

                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Text("Focus Time in Minutes")
                            .font(Font.custom("Noteworthy", size: 34))
                            .padding(.bottom, 10)
                            .foregroundColor(.black.opacity(0.7))
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        Picker("Timeframe", selection: $timeframeSelection) {
                            Text("Day").tag(0)
                            Text("Week").tag(1)
                            Text("Year").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 250)
                        .padding()
                        Spacer()
                    }

                    HStack {
                        Spacer()
                        CircularChartView(
                            data: getChartData(),
                            labels: getLabels(),
                            maxValue: getMaxValue()
                        )
                        .frame(height: 300)
                        .padding(.top, 50)
                        Spacer()
                    }
                }
                Spacer()
            }
        }
        
        .onAppear {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(darkGreen)
            
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black.withAlphaComponent(0.8)], for: .normal)
            fetchUserStats()
        }
    }

    private func fetchUserStats() {
        guard let userProfile = UserPreferences.userProfile else {
            print("User profile not found.")
            return
        }
        
        let userID = userProfile.userID
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        
        do {
            let focusSessions = try dbManager.fetchFocusSessionsForUser(userID: userID)
            let today = Calendar.current.startOfDay(for: Date())
            let currentWeekDay = Calendar.current.component(.weekday, from: Date())
            let startOfWeek = Calendar.current.date(byAdding: .day, value: -(currentWeekDay - 1), to: today)!
            let endOfWeek = Calendar.current.date(byAdding: .day, value: 7 - currentWeekDay, to: today)!

            var dailyData = Array(repeating: CGFloat(0), count: 24)
            var weeklyData = Array(repeating: CGFloat(0), count: 7)
            var yearlyData = Array(repeating: CGFloat(0), count: 12)

            for session in focusSessions {
                let sessionDetails = try dbManager.fetchFocusSessionDetails(sessionID: session)
                let startTime = sessionDetails.startTime
                let endTime = sessionDetails.endTime
                let duration = CGFloat(endTime.timeIntervalSince(startTime) / 60) // Convert to minutes

                if Calendar.current.isDate(startTime, inSameDayAs: today) {
                    let hourIndex = Int(dateFormatter.string(from: startTime))!
                    dailyData[hourIndex] += duration
                }

                if startTime >= startOfWeek && endTime <= endOfWeek {
                    let weekDay = Calendar.current.component(.weekday, from: startTime) - 1
                    weeklyData[weekDay] += duration
                }

                let month = Calendar.current.component(.month, from: startTime) - 1
                yearlyData[month] += duration
            }

            dayStats = dailyData
            weekStats = weeklyData
            yearStats = yearlyData
        } catch {
            print("Error fetching or processing user stats: \(error)")
        }
    }

    private func getChartData() -> [CGFloat] {
        switch timeframeSelection {
        case 0:
            return dayStats
        case 1:
            return weekStats
        case 2:
            return yearStats
        default:
            return []
        }
    }

    private func getMaxValue() -> CGFloat {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let month = calendar.component(.month, from: Date())

        let dateComponents = DateComponents(year: year, month: month)
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = CGFloat(range.count)
        
        switch timeframeSelection {
        case 0:
            return 60 // minutes in an hour
        case 1:
            return 24 * 60 // minutes in a day
        case 2:
            return numDays * 24 * 60 // minutes in current month
        default:
            return 1
        }
    }

    private func getLabels() -> [String] {
        switch timeframeSelection {
        case 0:
            return (0..<24).map { "\($0):00" }
        case 1:
            return Calendar.current.shortWeekdaySymbols
        case 2:
            return Calendar.current.shortMonthSymbols
        default:
            return []
        }
    }
}

#Preview {
    StatsView(presentSideMenu: .constant(true))
}
