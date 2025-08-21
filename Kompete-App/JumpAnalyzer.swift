import Vision

class JumpAnalyzer {
    func analyzeJump(from observations: [VNHumanBodyPoseObservation], fps: Double, calibrationFactor: Double) -> [Double] {
        let flightTimes = calculateFlightTimes(from: observations, fps: fps, calibrationFactor: calibrationFactor)
        return flightTimes.map { calculateJumpHeight(fromFlightTime: $0) }
    }

    private func calculateFlightTimes(from observations: [VNHumanBodyPoseObservation],
                                      fps: Double,
                                      calibrationFactor: Double) -> [Double] {
        var jumps = [Double]()
        let baselineHeight = establishInitialBaseline(observations: observations) // fixed baseline!
        var isAirborne = false
        var airborneStart: Int?

        // Adjust these for best detection results
        let detectionThreshold = 0.08
        let confirmationFrames = 1

        var airFrameCount = 0
        var groundFrameCount = 0

        for (index, observation) in observations.enumerated() {
            guard let currentHeight = try? observation.recognizedPoint(.rightAnkle).y else { continue }

            // Debug info
            print("Frame \(index): currentHeight = \(currentHeight), baseline = \(baselineHeight)")
            let heightDifference = Double(currentHeight) - baselineHeight
            print("heightDifference: \(heightDifference)")

            if heightDifference > detectionThreshold {
                groundFrameCount = 0
                airFrameCount += 1

                if !isAirborne && airFrameCount >= confirmationFrames {
                    airborneStart = index - confirmationFrames + 1
                    isAirborne = true
                    airFrameCount = 0
                    print("Jump start detected at frame \(airborneStart ?? -1)")
                }
            } else {
                airFrameCount = 0
                groundFrameCount += 1

                if isAirborne && groundFrameCount >= confirmationFrames {
                    isAirborne = false
                    if let start = airborneStart {
                        let flightFrames = index - start - confirmationFrames
                        let rawFlightTime = Double(flightFrames) / fps
                        let calibratedFlightTime = rawFlightTime * calibrationFactor
                        jumps.append(calibratedFlightTime)
                        print("Jump end detected at frame \(index), flight time: \(calibratedFlightTime)")
                    }
                    groundFrameCount = 0
                    airborneStart = nil
                }
            }
        }

        print("Detected jumps flight times: ", jumps)
        return jumps
    }

    private func establishInitialBaseline(observations: [VNHumanBodyPoseObservation]) -> Double {
        let initialFrames = observations.prefix(10)
        return initialFrames
            .compactMap { try? $0.recognizedPoint(.rightAnkle).y }
            .map { Double($0) }
            .average() ?? 0.0
    }

    private func calculateJumpHeight(fromFlightTime flightTime: Double) -> Double {
        return (9.81 * pow(flightTime, 2)) / 8
    }
}

// Helper extension
extension Array where Element == Double {
    func average() -> Double? {
        guard !isEmpty else { return nil }
        return reduce(0, +) / Double(count)
    }
}
