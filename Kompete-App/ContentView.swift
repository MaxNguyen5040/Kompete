//
//  ContentView.swift
//  Kompete-App
//
//  Created by Max Nguyen on 11/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = "Home"
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            TestView()
                .tabItem {
                    Image(systemName: "figure.run")
                    Text("Test")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                
            ProgramView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Program")
                }
                
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}


#Preview {
    ContentView()
}
