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
    let deltaTime: Double = 0.002
    let lamda: Double = 2 * Double.pi * 5 * 0.002
    var motionManager = CMMotionManager()
    @State private var preAccX: Double = 0
    @State private var curAccX: Double = 0
    @State private var preSpdX: Double = 0
    @State private var curSpdX: Double = 0
    @State private var prePosX: Double = 0
    @State private var curPosX: Double = 0
    @State private var minPosX: Double = Double(Int.max)
    @State private var maxPosX: Double = 0
    
    
    @State private var accX : Double = 0
    @State private var accY : Double = 0
    @State private var accZ : Double = 0
    
    @State var progressValue: Float = 0.0
    @State var currentSet = 0
    @State var showModal = false
    @State var weight: Int = 0
    @State var currentRep: Int = 0

    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    CircularProgressView(progress: Double(progressValue))
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.7, height: geo.size.height * 0.7)
                    VStack{
                        Text(workItem.name)
                        Text(String(currentRep) + "/" + String(workItem.reps))
                    }
                }
                Spacer()
                if weight != 0 {
                    Text(String(weight) + "Kg")
                }
                Button("Add Weight") {
                    showModal = true
                    addSet()
                }
                .sheet(isPresented: $showModal) {
                    AddWieghtView(weight: $weight, currentWork: workItem, currentSet: currentSet)
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
                        curAccX = lowPassFilter(rawAcc: abs(data.acceleration.x), preAcc: preAccX)
                        curSpdX = preSpdX + 0.5 * (curAccX - preAccX) * deltaTime
                        if curSpdX > 0 {
                            curPosX = prePosX + 0.5 * (curSpdX - preSpdX) * deltaTime
                        }
                        if maxPosX < curPosX {
                            maxPosX = curPosX
                        }
                        if minPosX > curPosX {
                            minPosX = curPosX
                        }
                        preSpdX = curSpdX
                        preAccX = curAccX
                        curPosX = prePosX
                        print(curAccX, curSpdX, curPosX, maxPosX)
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
         if currentSet == workItem.set {
             print("123")
             WKInterfaceDevice.current().play(.notification)
         }
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

struct AddWieghtView: View {
    let disk = Array(stride(from: 5, to: 205, by: +5))
    @State private var selected = 0
    @State private var alpha = 0
    @Environment(\.dismiss) private var dismiss
    @Binding var weight: Int
    @StateObject var assistant = Assistant()
    @State private var test = ""
    let currentWork: item
    let currentSet: Int
    var body: some View {
        VStack {
            Picker("무게를 골라주세요", selection: $selected) {
                ForEach(0..<disk.count) {
                    Text(String(disk[$0]))
                }
            }
            Spacer()
            HStack {
                Stepper(String(disk[selected] + alpha), value: $alpha, in: -200...200)
            }
            Button("Add") {
                weight = disk[selected] + alpha
                assistant.addWeight([currentWork._id, String(currentSet), String(weight)])
                dismiss()
            }
            Text(String(assistant.workList))
        }
    }
}
