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
    @StateObject var assistant = Assistant()
    @State var listData = ListData()
    var body: some View {
        VStack {
            List(makeListData(str: assistant.workList)) { item in
                Section(header: Text(item.traget)) {
                    NavigationLink(destination: CountView(workItem: item)) {
                        WorkListCellView(workItem: item)
                    }
                }
            }
        }
    }
    
    func makeListData(str: String) -> [item] {
        var res = [item]()
        var temp = str.components(separatedBy: ["[", "{", "\n", "\t", ";", "]", "}", ","]).filter { $0 != "" && $0 != "Work " && $0 != " Work "}
        var index = 0
        if temp.count >= 5 {
            for i in temp {
                print(i)
            }
            while index < temp.count {
                let newItem = item(
                    traget: String(temp[index].split(separator: " = ").last!),
                    name: String(temp[index + 1].split(separator: " = ").last!),
                    set: Int(temp[index + 2].split(separator: " = ").last!)!,
                    reps: Int(temp[index + 3].split(separator: " = ").last!)!,
                    _id: String(temp[index + 4].split(separator: " = ").last!)
                )
                res.append(newItem)
                index += 5
            }
        }
        return res
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
