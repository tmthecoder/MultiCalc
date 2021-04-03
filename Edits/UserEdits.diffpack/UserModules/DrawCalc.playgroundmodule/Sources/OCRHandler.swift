import PencilKit
import Vision
import UIKit

public typealias OCRResultHandler = (String) -> ()

public class OCRHandler : NSObject, PKCanvasViewDelegate {
    
    let onResult: OCRResultHandler
    
    var timestamp: Int = 0
    
    public init(onResult: @escaping OCRResultHandler) {
        self.onResult = onResult
    }
    
    func getText(image: CGImage) {
        let requestHandler = VNImageRequestHandler(cgImage: image)
        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest(completionHandler: onRecognitionComplete)
        request.recognitionLanguages = ["en_US"]
        // Set the words to give precidence to when detecting (math terms)
        request.customWords = ["+", "-", "/", "*", "x", "÷", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "sin", "cos", "tan"]
        do {
            try requestHandler.perform([request])
        } catch {
            print("Request Error: \(error).")
        }
    }
    
    func onRecognitionComplete(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
            print(error)
            return
        }
        let recognizedStrings = observations.compactMap { observation in
            print(observation)
            let finalString = observation.topCandidates(1).first?.string
            self.onResult(finalString ?? "")
        }
    }
    
    public func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        self.timestamp = Int(round(Date().timeIntervalSince1970 * 1000)) 
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 1.5) {
            let nowTime = Int(round(Date().timeIntervalSince1970 * 1000)) 
            print(nowTime - self.timestamp)
            if Int(nowTime) - self.timestamp < 1500 {
                return
            }
            if canvasView.drawing.strokes.count == 0 {
                return
            }
            let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
            self.getText(image: image.cgImage!)
        }
    }
}
