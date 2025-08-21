//
//  TestView.swift
//  Kompete-App
//
//  Created by Max Nguyen on 11/12/24.
//

import SwiftUI

struct TestView: View {
    
    let leaderboardData = [
        LeaderboardEntry(rank: "1", name: "John D.", score: "9.1s", isUser: false),
        LeaderboardEntry(rank: "2", name: "Sarah M.", score: "9.3s", isUser: false),
        LeaderboardEntry(rank: "3", name: "Mike R.", score: "9.4s", isUser: false),
        LeaderboardEntry(rank: "4", name: "Emma L.", score: "9.8s", isUser: false),
        LeaderboardEntry(rank: "5", name: "You", score: "10.2s", isUser: true),
        LeaderboardEntry(rank: "6", name: "Alex K.", score: "10.5s", isUser: false),
        LeaderboardEntry(rank: "7", name: "David P.", score: "10.7s", isUser: false),
        LeaderboardEntry(rank: "8", name: "Lisa M.", score: "10.9s", isUser: false),
        LeaderboardEntry(rank: "9", name: "Chris B.", score: "11.2s", isUser: false),
        LeaderboardEntry(rank: "10", name: "Rachel S.", score: "11.4s", isUser: false)
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Performance Section
            VStack(alignment: .leading) {
                Text("Your Performance")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    StatCard(title: "Best Sprint", value: "10.2s", change: "+0.3s")
                    StatCard(title: "Best Jump", value: "24in", change: "-2in")
                }
                .padding(.horizontal)
            }
            
            // Leaderboard Section
            VStack(alignment: .leading) {
                Text("Leaderboard")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(leaderboardData) { entry in
                            LeaderboardRow(rank: entry.rank,
                                           name: entry.name,
                                           score: entry.score,
                                           isUser: entry.isUser)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
            
            
            
        }}
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: String
    let name: String
    let score: String
    let isUser: Bool
}

// Keep existing StatCard and LeaderboardRow views...


struct StatCard: View {
    let title: String
    let value: String
    let change: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(change)
                .font(.caption)
                .foregroundColor(change.hasPrefix("+") ? .red : .green)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct LeaderboardRow: View {
    let rank: String
    let name: String
    let score: String
    let isUser: Bool
    
    var body: some View {
        HStack {
            Text(rank)
                .font(.headline)
                .frame(width: 30)
            Text(name)
                .font(.body)
                .fontWeight(isUser ? .bold : .regular)
            Spacer()
            Text(score)
                .font(.body)
        }
        .padding()
        .background(isUser ? Color.blue.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(8)
    }
}


#Preview {
    TestView()
}
