import Vision

class SprintAnalyzer {
    func analyzeSprint(from observations: [VNHumanBodyPoseObservation], fps: Double, calibrationFactor: Double) -> (Double, Double) {
        // Computer Vision setup for object detection
        var pixelScale: Double = 1.0
        let objectDetector = ObjectDetector()
        
//        // Process first frame to detect calibration object
//        if let firstObservation = observations.first,
//           let imageBuffer = firstObservation.pixelBuffer {
//            pixelScale = objectDetector.detectScale(in: imageBuffer)
//        }

        // Calculate average x-coordinate of the first few frames
        var initialXCoordinates: [Double] = []
        let initialFramesThreshold = min(10, observations.count)
        
        for (index, observation) in observations.enumerated() {
            if index >= initialFramesThreshold { break }
            
            if let footJoint = try? observation.recognizedPoint(.root) {
                initialXCoordinates.append(Double(footJoint.x))
            }
        }
        
        guard !initialXCoordinates.isEmpty else { return (0,0) }
        
        let averageInitialXCoordinate = initialXCoordinates.reduce(0, +) / Double(initialXCoordinates.count)
        
        // Movement detection
        var firstTurnaroundFrame: Int?
        var secondTurnaroundFrame: Int?
        var startFrame: Int?
        var movementDetected = false
        var xframe: [Int] = []
        var xposition: [Double] = []
        
        for (index, observation) in observations.enumerated() {
            guard let footJoint = try? observation.recognizedPoint(.root) else { continue }
            let xCoordinate = Double(footJoint.x)
            
            if !movementDetected && abs(xCoordinate - averageInitialXCoordinate) > 0.05 {
                movementDetected = true
                startFrame = index
            }
            
            guard movementDetected else { continue }
            
            xposition.append(xCoordinate)
            xframe.append(index)
            
            if firstTurnaroundFrame == nil && abs(xCoordinate - averageInitialXCoordinate) > 0.2 {
                firstTurnaroundFrame = index
            } else if firstTurnaroundFrame != nil && secondTurnaroundFrame == nil && abs(xCoordinate - averageInitialXCoordinate) < 0.2 {
                secondTurnaroundFrame = index
                break
            }
        }
        
        guard let secondTurnaroundFrame = secondTurnaroundFrame,
              let startFrame = startFrame else { return (0,0) }
        
        // Calculate times
        let secondTurnaroundTime = Double(secondTurnaroundFrame) / fps
        let startTime = Double(startFrame) / fps
        let sprint_time = secondTurnaroundTime - startTime
        
        // Calculate max speed
        var max_speed = 0.0
        let frame_offset = Int(fps)
        for index in 0..<(xposition.count - frame_offset) {
            let speed = (xposition[index + frame_offset] - xposition[index]) * pixelScale
            if speed > max_speed { max_speed = speed }
        }
        
        // Apply calibration with pixel scale
        let calibrated_time = sprint_time * calibrationFactor * pixelScale
        
        return (calibrated_time, max_speed)
    }
}

// Computer Vision helper
class ObjectDetector {
    func detectScale(in pixelBuffer: CVPixelBuffer) -> Double {
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        let objectDetectionRequest = VNDetectRectanglesRequest()
        objectDetectionRequest.minimumConfidence = 0.9
        objectDetectionRequest.minimumAspectRatio = 0.2
        objectDetectionRequest.maximumObservations = 1
        
        try? requestHandler.perform([objectDetectionRequest])
        
        guard let results = objectDetectionRequest.results,
              let firstObject = results.first else { return 1.0 }
        
        // Known real-world size of calibration object (in meters)
        let knownObjectWidth = 0.2 // 20cm cone/ball
        let pixelWidth = Double(firstObject.boundingBox.width) * Double(CVPixelBufferGetWidth(pixelBuffer))
        
        return knownObjectWidth / pixelWidth
    }
}
