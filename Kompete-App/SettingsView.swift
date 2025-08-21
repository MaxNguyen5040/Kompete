import SwiftUI

struct SettingsView: View {
    // MARK: - AppStorage Properties
    @AppStorage("units") private var units = "Imperial"
    @AppStorage("isLightMode") private var isLightMode = false
    @AppStorage("isPersonalizedData") private var isPersonalizedData = true
    @AppStorage("isHapticFeedbackEnabled") private var isHapticFeedbackEnabled = true

    // This environment value reads the system's color scheme
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            Form {
                // MARK: - General Settings
                Section(header: Text("General")) {
                    Picker(selection: $units) {
                        Text("Imperial (ft, lbs)").tag("Imperial")
                        Text("Metric (m, kg)").tag("Metric")
                    } label: {
                        Label("Units", systemImage: "scalemass")
                    }
                    
                    Toggle(isOn: $isLightMode) {
                        Label("Force Light Mode", systemImage: "lightbulb")
                    }
                    
                    Toggle(isOn: $isHapticFeedbackEnabled) {
                        Label("Haptic Feedback", systemImage: "iphone.radiowaves.left.and.right")
                    }
                }
                
                // MARK: - Data & Privacy
                Section(header: Text("Data & Privacy"), footer: Text("Allow the app to use your data to provide personalized insights and improve our services.")) {
                    Toggle(isOn: $isPersonalizedData) {
                        Label("Personalized Data", systemImage: "person.badge.key")
                    }
                }
                
                // MARK: - Accessibility Settings
                Section(header: Text("Accessibility"), footer: Text("This app respects your device's accessibility settings. You can configure them in the Settings app.")) {
                    // Link to the main Settings app
                    Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                        Label("Open Device Settings", systemImage: "gear")
                    }
                }
            }
            .navigationTitle("Settings")
            // This modifier applies the color scheme change instantly
            .preferredColorScheme(isLightMode ? .light : nil)
            .onChange(of: isPersonalizedData) { newValue in
                // This now gets called whenever the toggle is flipped
                DataSettings.updateDataPreferences(enabled: newValue)
                print("Personalized data preference updated to: \(newValue)")
            }
        }
        .navigationViewStyle(.stack) // Ensures it looks correct on iPad
    }
}

// MARK: - Helper Structs
struct UnitSettings {
    static func convertToMeters(_ value: Double) -> Double {
        return value * 0.3048 // Convert feet to meters
    }
    
    static func convertToFeet(_ value: Double) -> Double {
        return value / 0.3048 // Convert meters to feet
    }
}

struct DataSettings {
    static func updateDataPreferences(enabled: Bool) {
        // Here you would add your logic for handling data, e.g., enabling/disabling analytics
        print("Data collection preference is now: \(enabled ? "ON" : "OFF")")
        UserDefaults.standard.set(enabled, forKey: "dataCollection")
    }
}

#Preview {
    SettingsView()
}
