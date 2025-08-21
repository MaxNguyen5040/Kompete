import Vision
import AVFoundation

class PoseDetector {
    func detectPose(in videoURL: URL, completion: @escaping ([VNHumanBodyPoseObservation]?, Double?) -> Void) {
        let asset = AVAsset(url: videoURL)
        
        asset.loadTracks(withMediaType: .video) { tracks, error in
            if let error = error {
                print("Failed to load video tracks: \(error)")
                completion(nil, nil)
                return
            }
            
            guard let track = tracks?.first else {
                print("Failed to find video track")
                completion(nil, nil)
                return
            }
            
            // Load tracks first, then access nominalFrameRate synchronously
            let fps = track.nominalFrameRate
            
            // Configure settings to extract video frames
            let outputSettings: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            
            let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
            
            // Create an asset reader
            guard let assetReader = try? AVAssetReader(asset: asset) else {
                print("Failed to create asset reader")
                completion(nil, nil)
                return
            }
            
            assetReader.add(readerOutput)
            
            // Start reading frames
            assetReader.startReading()
            
            var observations: [VNHumanBodyPoseObservation] = []
            
            while let sampleBuffer = readerOutput.copyNextSampleBuffer(),
                  let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                let request = VNDetectHumanBodyPoseRequest()
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
                
                do {
                    try handler.perform([request])
                    if let result = request.results {
                        observations.append(contentsOf: result)
                    }
                } catch {
                    print("Failed to perform pose detection on frame: \(error)")
                }
            }
            
            completion(observations.isEmpty ? nil : observations, Double(fps))
        }
    }
}
