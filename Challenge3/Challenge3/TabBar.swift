//
//  MindfulnessView.swift
//  Challenge3
//
//  Created by Federica Ziaco on 13/12/24.
//


import SwiftUI


struct TabBar : View {
    var body: some View {
        TabView {
            Tab("Diary", systemImage: "square.and.pencil") {
                MainView()
            }

            Tab("Mindfulness", systemImage: "brain") {
                MindfulnessView()
            }
            
            
        
        }
    }
}

#Preview {
    TabBar()
}
 

