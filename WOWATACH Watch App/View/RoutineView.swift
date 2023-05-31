//
//  RoutineView.swift
//  WOWATACH Watch App
//
//  Created by 오예준 on 2023/05/31.
//

import SwiftUI


struct item: Identifiable {
    var id = UUID()
    var traget: String
    var name: String
    var set: Int
}

struct RoutineView: View {
    // 임시 데이터
    var listData: [item] = [
        item(traget: "가슴", name: "벤치 프레스", set: 4),
        item(traget: "가슴", name: "딥스", set: 4),
        item(traget: "가슴", name: "인클라인 프레스", set: 4)
    ]
    var body: some View {
        VStack {
            List(listData) { item in
                Section(header: Text(item.traget)) {
                    NavigationLink(destination: CountView(workItem: item)) {
                        WorkListCellView(workItem: item)
                    }
                }
            }
        }
    }
}
struct WorkListCellView: View {
    var workItem: item
    var body: some View {
        Text(workItem.name + String(workItem.set))
    }
}

struct RoutineView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineView()
    }
}
