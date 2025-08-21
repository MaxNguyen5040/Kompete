//
//  ProfileView.swift
//  Kompete-App
//
//  Created by Max Nguyen on 11/12/24.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            // Existing Profile Header
            VStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                Text("Test User")
                Text("Joined on 12/18/24")
                    .font(.caption)
            }
            .padding()
            
            // Run Tests Section
            VStack(alignment: .leading) {
                Text("Run Tests")
                    .font(.headline)
                    .padding()
                
                Group {
                    HStack {
                        Text("Best sprint time:")
                        Spacer()
                        Text("10.03")
                    }
                    HStack {
                        Text("Previous sprint time:")
                        Spacer()
                        Text("12.04")
                    }
                }
                .padding(.horizontal)
            }
            
            // Jump Tests Section
            VStack(alignment: .leading) {
                Text("Jump Tests")
                    .font(.headline)
                    .padding()
                
                Group {
                    HStack {
                        Text("Best jump height:")
                        Spacer()
                        Text("2 ft")
                    }
                    HStack {
                        Text("Previous jump height:")
                        Spacer()
                        Text("1.7 ft")
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            
        }
    }
}



#Preview {
    ProfileView()
}
