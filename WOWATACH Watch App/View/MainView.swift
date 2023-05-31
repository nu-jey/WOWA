//
//  MainView.swift
//  WOWATACH Watch App
//
//  Created by 오예준 on 2023/05/31.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack{
                Text("WOWA")
                NavigationLink("페이지 이동", destination: RoutineView())
            }
        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
