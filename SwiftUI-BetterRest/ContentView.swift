//
//  ContentView.swift
//  SwiftUI-BetterRest
//
//  Created by JimmyChao on 2024/3/15.
//

import SwiftUI
import CoreML

struct ContentView: View {
    
    @State private var sleepAmount: Double = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    static private var defaultWakeTime: Date {
        var component = DateComponents()
        component.hour = 7
        component.minute = 0
        let date = Calendar.current.date(from: component)
        return date ?? Date.now
    }
    
    private var calculation: String {
        var result = ""
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hourInSec = (components.hour ?? 0) * 60 * 60
            let minuteInSec = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(
                wake: Int64(hourInSec + minuteInSec),
                estimatedSleep: sleepAmount,
                coffee: Int64(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            result = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            print(error)
            alertTitle = "Error"
            alertMessage = "Something is not right"
            showingAlert = true
        }
        
        return result
    }
    
    var body: some View {

        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Desire amount of sleep")
                        .font(.headline)
                    
                    Stepper(
                        "\(sleepAmount.formatted()) hours",
                        value: $sleepAmount,
                        in: 4...10, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("When do you want to wake up ?")
                        .font(.headline)
                    
                    DatePicker(
                        "Please enter a time",
                        selection: $wakeUp,
                        displayedComponents: .hourAndMinute)
                }
                
                
                Section("Daily coffee intake") {
                    Stepper(
                        "\(coffeeAmount) cups",
                        value: $coffeeAmount,
                        in: 1...20)
                }
                
                Section("result") {
                    Text("You should sleep at \(calculation)").font(.subheadline)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 600)
            .background(.ultraThickMaterial)
            .clipShape(.rect(cornerRadius: 20))
            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            .padding()
            .navigationTitle("Better Rest")
            
        }.alert(alertTitle, isPresented: $showingAlert) {
            Button("Okay") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    func test() {
        var component = DateComponents()
        component.month = 10
        component.day = 20
        var date = Calendar.current.date(from: component)
    }
}

#Preview {
    ContentView()
}
