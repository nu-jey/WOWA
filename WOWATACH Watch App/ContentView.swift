//
//  ContentView.swift
//  WOWATACH Watch App
//
//  Created by 오예준 on 2023/05/28.
//

import SwiftUI
import CoreMotion
struct ContentView: View {
    let lamda: Double = 2 * Double.pi * 5 * 0.002
    
    var motionManager = CMMotionManager()
    @State private var accX : Double = 0
    @State private var accY : Double = 0
    @State private var accZ : Double = 0
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("\(accX)")
            Text("\(accY)")
            Text("\(accZ)")
            Button("버튼") {
                print("button pressed")
            }
        }
        .padding()
        .onAppear {
            if motionManager.isAccelerometerAvailable {
                motionManager.accelerometerUpdateInterval = 1.0 / 60.0
                motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                    guard let data = data, error == nil else {
                        return
                    }
                    print(data.acceleration.x, data.acceleration.y, data.acceleration.z)
                    accX = lowPassFilter(rawAcc: data.acceleration.x, preAcc: accX)
                    accY = lowPassFilter(rawAcc: data.acceleration.x, preAcc: accY)
                    accZ = lowPassFilter(rawAcc: data.acceleration.x, preAcc: accZ)
                }
            }
        }
    }
    func lowPassFilter(rawAcc: Double, preAcc: Double) -> Double {
        return lamda / (1 + lamda) * rawAcc + 1 / (1 + lamda) * preAcc
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

