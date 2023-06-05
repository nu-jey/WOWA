//
//  MainView.swift
//  WOWATACH Watch App
//
//  Created by 오예준 on 2023/05/31.
//

import SwiftUI
import RealmSwift

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack{
                Text("WOWA")
                NavigationLink("Today Schedule", destination: RoutineView())
            }
        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}


