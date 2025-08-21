import Vision

class SquatAnalyzer {
    func analyzeSquat(from observations: [VNHumanBodyPoseObservation], fps: Double, calibrationFactor: Double) -> (depthPercentage: Double, repCount: Int, descentVelocity: Double, ascentVelocity: Double) {
        guard let initialY = establishInitialBaseline(observations: observations) else {
            print("Could not establish a baseline height.")
            return (0, 0, 0, 0)
        }

        var inSquat = false
        var repCount = 0
        var maxDepthForSet: Double = 0
        var velocities: [Double] = []

        // A squat starts when the hip drops below 85% of standing height
        let squatThreshold = initialY * 0.85
        // A rep is completed when the hip returns above 90% of standing height
        let standingThreshold = initialY * 0.90 // <-- WIDENED GAP

        for (index, observation) in observations.enumerated() {
            guard let hipPoint = try? observation.recognizedPoint(.rightHip), hipPoint.confidence > 0.5 else {
                continue
            }
            let currentY = Double(hipPoint.y)

            // --- BETTER LOGGING: See all values in real-time ---
            print("Frame \(index): currentY = \(String(format: "%.3f", currentY)) | squatThreshold = \(String(format: "%.3f", squatThreshold)) | standingThreshold = \(String(format: "%.3f", standingThreshold)) | inSquat = \(inSquat)")

            // State Machine Logic
            if !inSquat {
                if currentY < squatThreshold {
                    inSquat = true
                    print("--> SQUAT STARTED at frame \(index)")
                }
            } else { // We are currently in a squat
                if currentY > standingThreshold {
                    inSquat = false
                    repCount += 1
                    print("--> REP #\(repCount) COMPLETED at frame \(index)")
                }
            }

            // Other Metrics Calculation
            let currentDepth = (initialY - currentY) / initialY
            maxDepthForSet = max(maxDepthForSet, currentDepth)

            if index > 0, let prevHipPoint = try? observations[index - 1].recognizedPoint(.rightHip) {
                let prevY = Double(prevHipPoint.y)
                let deltaY = currentY - prevY
                let velocity = (deltaY * fps) * calibrationFactor
                velocities.append(velocity)
            }
        }

        // Calculate peak velocities
        let ascentVelocities = velocities.filter { $0 > 0 }
        let descentVelocities = velocities.filter { $0 < 0 }
        
        let peakAscent = ascentVelocities.max() ?? 0
        let peakDescent = abs(descentVelocities.min() ?? 0)

        print("Total reps detected: \(repCount)")
        return (maxDepthForSet * 100, repCount, peakDescent, peakAscent)
    }

    private func establishInitialBaseline(observations: [VNHumanBodyPoseObservation]) -> Double? {
        let initialFrames = observations.prefix(15)
        let baselineHeights = initialFrames
            .compactMap { try? $0.recognizedPoint(.rightHip) }
            .filter { $0.confidence > 0.5 }
            .map { Double($0.y) }
        
        guard !baselineHeights.isEmpty else { return nil }
        return baselineHeights.reduce(0, +) / Double(baselineHeights.count)
    }
}
