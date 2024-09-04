//
//  TimePickerView.swift
//  TripMaker
//
//  Created by Kejia Liu on 2024-03-27.
//

import SwiftUI

struct TimePickerView: View {
    @Binding var selectedHours: Int
    @Binding var selectedMinutes: Int
    @Binding var selectedSeconds: Int

    let hours: [Int] = Array(0...23)
    let minutesAndSeconds: [Int] = Array(0...59)
    let lightGreen = Color(UIColor(red: 25/255.0, green: 255/255.0, blue: 5/255.0, alpha: 1.0))

    var body: some View {
        HStack {
            // Hours Picker
            Picker(selection: $selectedHours, label: Text("Hours")) {
                ForEach(hours, id: \.self) { hour in
                    Text("\(hour) h")
                        .font(Font.custom("Noteworthy", size: 22))
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: 100)
            .clipped()
            .tint(.white)
            .colorMultiply(lightGreen)
            
            // Minutes Picker
            Picker(selection: $selectedMinutes, label: Text("Minutes")) {
                ForEach(minutesAndSeconds, id: \.self) { minute in
                    Text("\(minute) m")
                        .font(Font.custom("Noteworthy", size: 22))
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: 100)
            .clipped()
            .tint(.white)
            .colorMultiply(lightGreen)
            
            
            // Seconds Picker
            Picker(selection: $selectedSeconds, label: Text("Seconds")) {
                ForEach(minutesAndSeconds, id: \.self) { second in
                    Text("\(second) s")
                        .font(Font.custom("Noteworthy", size: 22))
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: 100)
            .clipped()
            .tint(.white)
            .colorMultiply(lightGreen)
        }
        .compositingGroup()
        .tint(.white)
        .colorMultiply(lightGreen)
    }
}


#Preview {
    TimePickerView(selectedHours: .constant(1), selectedMinutes: .constant(30), selectedSeconds: .constant(15))
}
