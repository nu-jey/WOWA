//
//  RoutineView.swift
//  WOWATACH Watch App
//
//  Created by 오예준 on 2023/05/31.
//

import SwiftUI
import RealmSwift


struct item: Identifiable {
    var id = UUID()
    var traget: String
    var name: String
    var set: Int
    var reps: Int
    var _id: String
}
class ListData {
    var data = [item]()
}

struct RoutineView: View {
    var data: [item]
    var body: some View {
        VStack {
            WorkProgressView(workId: data.map { $0._id })
            List(data) { item in
                Section(header: Text(item.traget)) {
                    NavigationLink(destination: CountView(workItem: item)) {
                        WorkListCellView(workItem: item, check: false)
                    }
                }
            }
        }
    }
    
}

struct WorkListCellView: View {
    var workItem: item
    var check: Bool
    var body: some View {
        HStack {
            if check {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .frame(width: 15, height: 15)
            } else {
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: 15, height: 15)
            }
            Spacer()
            Text(workItem.name)
            Spacer()
            Text(String(workItem.set) + " Set")
            
        }
    }
}

struct WorkProgressView: View {
    var workId: [String]
    @State var progressValue: Double = 0.5
    var body: some View {
        ProgressView(value: progressValue)
            .progressViewStyle(LinearProgressViewStyle(tint: .red))
            .padding()
    }
}

struct RoutineView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineView(data: [item(traget: "가슴", name: "벤치 프레스", set: 4, reps: 10, _id: "123")])
    }
}
