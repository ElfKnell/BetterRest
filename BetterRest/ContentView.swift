//
//  ContentView.swift
//  BetterRest
//
//  Created by Andrii Kyrychenko on 19/07/2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        
        let sleepA = Binding(
            get: {self.sleepAmount},
            set: {self.sleepAmount = $0
                calculateBedtime()
            }
        )
        
        let wakeup = Binding(
            get: {self.wakeUp},
            set: {self.wakeUp = $0
                calculateBedtime()
            }
        )
        
        NavigationView {
            Form {
                Section {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: wakeup, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                } header: {
                    Text("Wake up")
                }
                
                Section {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted())", value: sleepA, in: 4...12, step: 0.25)
                } header: {
                    Text("Sleep Amount")
                }
                
                Section {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Picker(coffeeAmount == 0 ? "1 cup" : "\(coffeeAmount + 1) cups", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text("\($0)")
                        }
                    }
                } header: {
                    Text("Cups of coffee")
                }
                
                Section {
                    Text(alertTitle)
                    Text(alertMessage)
                        .font(.headline)
                }
                
            }
            .navigationTitle("BetterRest")
            .task {
                calculateBedtime()
            }
        }
    }
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount + 1))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
