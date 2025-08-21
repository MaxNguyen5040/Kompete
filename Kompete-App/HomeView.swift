import SwiftUI
import UIKit
import PhotosUI
import AVFoundation

struct HomeView: View {
    // MARK: - State Properties
    @State private var isShowingCamera = false
    @State private var isShowingVideoPicker = false
    @State private var videoURL: URL?
    @State private var selectedTestType: TestType = .verticalJump
    @State private var testResult: Double?
    @State private var isAnalyzing = false
    @State private var videoThumbnail: UIImage?
    @AppStorage("units") private var units = "Imperial"

    // MARK: - Analyzers
    private let poseDetector = PoseDetector()
    private let jumpAnalyzer = JumpAnalyzer()
    private let sprintAnalyzer = SprintAnalyzer()
    private let squatAnalyzer = SquatAnalyzer()

    // MARK: - TestType Enum
    enum TestType: CaseIterable {
        case verticalJump
        case sprint
        case squat
        case functionalMovementScreen
        case athleteReadinessTest
        case rangeOfMotionTest

        var name: String {
            switch self {
            case .verticalJump: return "Vertical Jump"
            case .sprint: return "5-10-5 Sprint"
            case .squat: return "Squat"
            case .functionalMovementScreen: return "Functional Movement Screen (Currently Debugging)"
            case .athleteReadinessTest: return "Athlete Readiness Test (Currently Debugging)"
            case .rangeOfMotionTest: return "Range of Motion Test (Currently Debugging)"
            }
        }

        var iconName: String {
            switch self {
            case .verticalJump: return "arrow.up.circle"
            case .sprint: return "figure.run"
            case .squat: return "figure.strengthtraining.traditional"
            case .functionalMovementScreen: return "waveform.path"
            case .athleteReadinessTest: return "figure.wave"
            case .rangeOfMotionTest: return "gauge"
            }
        }

        var color: Color {
            switch self {
            case .verticalJump: return .purple
            case .sprint: return .blue
            case .squat: return .orange
            case .functionalMovementScreen: return .green
            case .athleteReadinessTest: return .teal
            case .rangeOfMotionTest: return .pink
            }
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Kompete")
                    .font(.largeTitle.bold())
                    .padding(.top, 24)

                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(.systemGray6))
                        .frame(height: 180)
                        .shadow(color: Color.black.opacity(0.07), radius: 4, x: 0, y: 2)

                    if let thumbnail = videoThumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 240)
                    } else {
                        Image("sprint111") // Your placeholder image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 240)
                    }
                }

                Group {
                    if let result = testResult {
                        getResultText(for: selectedTestType, result: result)
                            .font(.title2.weight(.semibold))
                            .foregroundColor(selectedTestType.color)
                            .padding(.top, 10)
                    } else if isAnalyzing {
                        ProgressView("Analyzing test...")
                            .padding(.top, 10)
                    } else {
                        Text("Select a workout and record or upload a video to analyze.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.top, 10)
                    }
                }
                .animation(.easeInOut, value: testResult)
                .padding(.bottom, 10)

                List {
                    ForEach(TestType.allCases, id: \.self) { type in
                        HStack(spacing: 16) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(type.color.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: type.iconName)
                                        .font(.system(size: 22, weight: .medium))
                                        .foregroundColor(type.color)
                                }
                                Text(type.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                            
                            // Record Button
                            Button(action: {
                                print("Record Button Tapped")
                                self.selectedTestType = type
                                self.isShowingVideoPicker = false
                                self.isShowingCamera = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "camera.fill")
                                    Text("Record")
                                }
                                .font(.footnote.bold())
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 18)
                                .background(type.color)
                                .cornerRadius(10)
                            }
                            .buttonStyle(.borderless) // <-- THE FIX

                            // Upload Button
                            Button(action: {
                                print("Upload Button Tapped")
                                self.selectedTestType = type
                                self.isShowingCamera = false
                                self.isShowingVideoPicker = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "tray.and.arrow.up.fill")
                                    Text("Upload")
                                }
                                .font(.footnote.bold())
                                .foregroundColor(type.color)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 18)
                                .background(type.color.opacity(0.18))
                                .cornerRadius(10)
                            }
                            .buttonStyle(.borderless) // <-- THE FIX
                        }
                        .padding(.vertical, 6)
                    }
                }
                .listStyle(.plain)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingCamera) {
                CameraView { url in
                    self.videoURL = url
                    self.processVideo()
                }
            }
            .sheet(isPresented: $isShowingVideoPicker) {
                VideoPicker(videoURL: $videoURL) {
                    self.processVideo()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    @ViewBuilder
    private func getResultText(for testType: TestType, result: Double) -> some View {
        switch testType {
        case .verticalJump:
            // Check the selected unit and format the text accordingly
            if units == "Metric" {
                // The 'result' from your analyzer is in meters, so just display it
                Text("Jump Height: \(String(format: "%.2f", result)) meters")
            } else {
                // Convert meters to feet for Imperial display
                let heightInFeet = result / 0.3048 // 1 foot = 0.3048 meters
                Text("Jump Height: \(String(format: "%.2f", heightInFeet)) feet")
            }

        case .sprint:
            // Time is the same in both systems
            Text("Sprint Time: \(String(format: "%.2f", result)) seconds")

        case .squat:
            // Reps are the same in both systems
            Text("Squat Reps: \(String(format: "%.0f", result)) squats")
            
        case .functionalMovementScreen, .athleteReadinessTest, .rangeOfMotionTest:
            // Handle your other tests here
            Text("Placeholder Result")
        }
    }


    private func analyzeJump(video: URL) {
        isAnalyzing = true
        poseDetector.detectPose(in: video) { observations, fps in
            if let observations = observations, let fps = fps {
                let calibrationFactor = 1.65
                let height = jumpAnalyzer.analyzeJump(from: observations, fps: fps, calibrationFactor: calibrationFactor)
                print("HEIGHT!", height)
                DispatchQueue.main.async {
                    self.testResult = height.max()
                    self.isAnalyzing = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                }
            }
        }
    }

    private func analyzeSprint(video: URL) {
        isAnalyzing = true
        poseDetector.detectPose(in: video) { observations, fps in
            if let observations = observations, let fps = fps {
                let calibrationFactor = 2.82
                let (time, _) = sprintAnalyzer.analyzeSprint(from: observations, fps: fps, calibrationFactor: calibrationFactor)
                DispatchQueue.main.async {
                    self.testResult = time
                    self.isAnalyzing = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                }
            }
        }
    }

    private func analyzeSquat(video: URL) {
        isAnalyzing = true
        poseDetector.detectPose(in: video) { observations, fps in
            if let observations = observations, let fps = fps {
                let calibrationFactor = 0.393
                let (_, reps, _, _) = squatAnalyzer.analyzeSquat(from: observations, fps: fps, calibrationFactor: calibrationFactor)
                DispatchQueue.main.async {
                    self.testResult = Double(reps)
                    self.isAnalyzing = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                }
            }
        }
    }

    private func processVideo() {
        guard let url = videoURL else { return }

        if let image = generateThumbnail(url: url) {
            self.videoThumbnail = image
        }

        switch selectedTestType {
        case .verticalJump:
            analyzeJump(video: url)
        case .sprint:
            analyzeSprint(video: url)
        case .squat:
            analyzeSquat(video: url)
        case .functionalMovementScreen:
            analyzeJump(video: url)  // Placeholder analyzers; customize as needed
        case .athleteReadinessTest:
            analyzeJump(video: url)
        case .rangeOfMotionTest:
            analyzeJump(video: url)
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    var onVideoCaptured: (URL) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.cameraCaptureMode = .video
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                picker.dismiss(animated: true) {
                    self.parent.onVideoCaptured(videoURL)
                }
            }
        }
    }
}

func generateThumbnail(url: URL) -> UIImage? {
    let asset = AVURLAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    // Midway time — half the video duration
    let midpoint = CMTimeMultiplyByFloat64(asset.duration, multiplier: 0.5)
    
    do {
        let cgImage = try imageGenerator.copyCGImage(at: midpoint, actualTime: nil)
        return UIImage(cgImage: cgImage)
    } catch {
        print("Error generating thumbnail: \(error.localizedDescription)")
        return nil
    }
}


#Preview {
    HomeView()
}
