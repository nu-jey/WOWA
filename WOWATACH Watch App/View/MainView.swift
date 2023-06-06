//
//  MainView.swift
//  WOWATACH Watch App
//
//  Created by 오예준 on 2023/05/31.
//

import SwiftUI
import RealmSwift

struct MainView: View {
    @StateObject var assistant = Assistant()
    var body: some View {
        NavigationView {
            VStack{
                Text("WOWA")
                NavigationLink("Today Schedule", destination: RoutineView(data: makeListData(str: assistant.workList)))
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}


