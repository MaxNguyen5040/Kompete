//
//  ProgramView.swift
//  Kompete-App
//
//  Created by Max Nguyen on 11/12/24.
//
import SwiftUI
import CalendarKit
import EventKit


struct ProgramView: View {
    @State private var selectedDate = Date()
    @State private var exercises: [Exercise] = [
        Exercise(date: "2025-01-05", description: "3 sets of 200m sprints", isCompleted: false),
        Exercise(date: "2025-01-07", description: "Vertical jump training", isCompleted: false),
        Exercise(date: "2025-01-13", description: "2 mile run", isCompleted: false),
        Exercise(date: "2025-01-15", description: "10 sets of 10 squats", isCompleted: false),
        Exercise(date: "2025-01-19", description: "2 mile run", isCompleted: false),
        Exercise(date: "2025-01-27", description: "Morning yoga session", isCompleted: false),
        Exercise(date: "2025-01-27", description: "Evening strength training", isCompleted: false),
        Exercise(date: "2025-01-28", description: "Cardio session", isCompleted: false),
        Exercise(date: "2025-01-30", description: "HIIT workout", isCompleted: false),
        Exercise(date: "2025-01-31", description: "Stretching and mobility", isCompleted: false)
    ]
    
    var body: some View {
        VStack {
            CalendarKitView()
                .overlay(
                    VStack {
                        Spacer()
                        if hasExercisesForSelectedDate() {
                            ExerciseOverlay(exercises: exercises)
                                .frame(height: 200)
                                .transition(.move(edge: .bottom))
                        }
                    }
                )
        }
    }
    
    private func hasExercisesForSelectedDate() -> Bool {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let selectedDateString = formatter.string(from: selectedDate)
            
            return exercises.contains { exercise in
                exercise.date == selectedDateString
            }
        }
}

struct CalendarKitView: UIViewControllerRepresentable {
    private let eventStore = EKEventStore()
    
    func makeUIViewController(context: Context) -> DayViewController {
        let dayViewController = DayViewController()
        dayViewController.dataSource = context.coordinator as? any EventDataSource
        return dayViewController
    }
    
    func updateUIViewController(_ uiViewController: DayViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(eventStore: eventStore)
    }
    
    class Coordinator: NSObject, EventDataSource {
        private let eventStore: EKEventStore
        
        init(eventStore: EKEventStore) {
            self.eventStore = eventStore
            super.init()
            requestAccess()
        }
        
        private func requestAccess() {
            eventStore.requestAccess(to: .event) { granted, error in
                if granted {
                    // Handle access granted
                }
            }
        }
        
        func eventsForDate(_ date: Date) -> [EventDescriptor] {
            let startDate = date.start
            let endDate = date.end
            
            let predicate = eventStore.predicateForEvents(withStart: startDate,
                                                        end: endDate,
                                                        calendars: nil)
            
            let events = eventStore.events(matching: predicate)
            return events.map { ekEvent in
                let event = Event()
                event.dateInterval = DateInterval(start: ekEvent.startDate,
                                               end: ekEvent.endDate)
                event.text = ekEvent.title
                event.color = .blue
                return event
            }
        }
    }
}

struct Exercise: Identifiable {
    let id = UUID()
    let date: String
    let description: String
    var isCompleted: Bool
}

struct ExerciseOverlay: View {
    let exercises: [Exercise]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommended Exercises")
                .font(.headline)
                .padding(.horizontal)
            
            Divider()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(exercises) { exercise in
                        ExerciseRow(exercise: exercise)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: exercise.isCompleted ? "checkmark.square" : "square")
            Text(exercise.description)
                .font(.subheadline)
        }
    }
}

// Helper extension for Date
extension Date {
    var start: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var end: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: start) ?? self
    }
}



#Preview {
    ProgramView()
}
