//
//  ContentView.swift
//  WOWATACH Watch App
//
//  Created by 오예준 on 2023/05/28.
//

import SwiftUI
import CoreMotion
struct CountView: View {
    var workItem: item
    let lamda: Double = 2 * Double.pi * 5 * 0.002
    
    var motionManager = CMMotionManager()
    @State private var accX : Double = 0
    @State private var accY : Double = 0
    @State private var accZ : Double = 0
    @State var progressValue: Float = 0.0
    @State var currentSet = 0
    @State var showModal = false
    var body: some View {
            GeometryReader { geo in
                VStack {
                    ZStack {
                        CircularProgressView(progress: Double(progressValue))
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.7, height: geo.size.height * 0.7)
                        Text(workItem.name)
                    }
                    Spacer()
                    NavigationLink(destination: AddWieghtView()) {
                        Text("Add Weight")
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
        
    }
    func lowPassFilter(rawAcc: Double, preAcc: Double) -> Double {
        return lamda / (1 + lamda) * rawAcc + 1 / (1 + lamda) * preAcc
    }
    func addSet() {
        currentSet += 1
        progressValue = Float(currentSet) / Float(workItem.set)
    }
}

struct CircularProgressView: View {
    var progress: Double
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .stroke(Color(.lightGray), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: CGFloat(self.progress))
                    .stroke(
                        Color.yellow,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round))
            }
            .rotationEffect(Angle(degrees: -90))
        }
    }
}

