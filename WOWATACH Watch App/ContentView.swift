//
//  ContentView.swift
//  WOWATACH Watch App
//
//  Created by 오예준 on 2023/05/28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(wowa.bodyPart.joined())
            Button("버튼") {
                print("button pressed")
            }
        }
        .padding()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

