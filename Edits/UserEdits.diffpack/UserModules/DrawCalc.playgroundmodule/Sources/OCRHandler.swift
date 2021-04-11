import PencilKit
import Vision
import UIKit

/// The format for the completion handler
public typealias OCRResultHandler = (String) -> ()

/// The class to handle all OCR requests and output a string representation of input
public class OCRHandler : NSObject {
    
    /// The completion handler to call when a result is found
    let onResult: OCRResultHandler
    /// The timestamp of the last OCR call
    var timestamp: Int = 0
    
    /// The initializer to set the completion handler
    public init(onResult: @escaping OCRResultHandler) {
        self.onResult = onResult
    }
    
    /// The method to get the textual representation of the handwritten input
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
    
    /// The method to handle the completion of a request
    /// Gets all results and if valid signals the completion handler
    func onRecognitionComplete(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
            print("Error obtaining recognitions")
            return
        }
        for observation in observations {
            let finalString = observation.topCandidates(1).first?.string
            self.onResult(finalString ?? "")
        }
    }
}

/// The PKCanvasViewDelegate delegate to handle any canvas changes
extension OCRHandler : PKCanvasViewDelegate{
    /// The method to handle any canvas drawing changes (from the delegate)
    /// Sets a 1.5 second delay on the OCR call and proceeds to call the recognizer if no changes were made
    public func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        // Get the current timestamp
        self.timestamp = Int(round(Date().timeIntervalSince1970 * 1000))
        // Set the following code to execute after a 1.5 sec delay
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 1.5) {
            // Make sure there were no changes within the delay period
            let nowTime = Int(round(Date().timeIntervalSince1970 * 1000))
            // Do nothing if there were changes
            if Int(nowTime) - self.timestamp < 1500 {
                return
            }
            // Call the OCR handler after getting the image from the canvas view
            DispatchQueue.main.async {
                let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
                DispatchQueue.global(qos: .userInteractive).async {
                    self.getText(image: image.cgImage!)
                }
            }
        }
    }
}
