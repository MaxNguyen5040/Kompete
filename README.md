# Kompete-App

Kompete-App is an iOS SwiftUI app for tracking and analyzing your athletic training and physical tests, using on-device video analysis and machine learning. You can log sprints, jumps, squats, and see all your training in one place.

---

## Features

- **Multiple Test Types:** Track vertical jump, sprint, squat, and more.
- **Video Analysis:** Instantly analyze movement by recording or uploading video.
- **Pose Detection:** Uses Vision to extract pose frames per test.
- **Units, Privacy & Theme:** Switch units (Imperial/Metric), enable Light Mode, haptic feedback, and control personalized analytics.
- **Training Calendar:** Calendar integration with daily recommended workouts.
- **Profile & Leaderboard:** Review personal records and see your standing.
- **Local Processing:** All pose analysis stays on your device—no cloud uploads.

---

## Structure

- `HomeView.swift`: Main interface for running/analyzing tests.
- `ProgramView.swift`: Calendar view, exercise scheduling.
- `ProfileView.swift`, `Leaderboard`: Stats and rankings.
- `PoseDetector.swift`, `JumpAnalyzer.swift`, `SprintAnalyzer.swift`, `SquatAnalyzer.swift`: Video/ML pipeline.
- `SettingsView.swift`: All user-adjustable options.

---

## Quick Setup

1. Clone repo, open in Xcode 15+.
2. Requires iOS 17+, Vision, and CalendarKit.
3. Add camera and photo permissions to `Info.plist`.
4. Run on a real device for full video features. Will not work using an Xcode simulator. 
