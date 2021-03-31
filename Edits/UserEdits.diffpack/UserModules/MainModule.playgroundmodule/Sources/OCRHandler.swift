import PencilKit
import Vision
import UIKit

public typealias OCRResultHandler = (String) -> ()

public class OCRHandler : NSObject, PKCanvasViewDelegate {
    
    let onResult: OCRResultHandler
    
    public init(onResult: @escaping OCRResultHandler) {
        self.onResult = onResult
    }
    
    func getText(image: CGImage) {
        let requestHandler = VNImageRequestHandler(cgImage: image)
        // Create a new request to recognize text.
        print("NEW")
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                print(error)
                return
            }
            print("OBSERVED")
            print(observations)
            let recognizedStrings = observations.compactMap { observation in
                print(observation)
                // Return the string of the top VNRecognizedText instance.
                observation.topCandidates(3).map { text in
                    print(text.string)
                }
            }
            print(recognizedStrings)
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en_US"]
        request.customWords = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "+", "-", "/", "*", "x", "sin", "cos"]
        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
//              print(request.observationInfo)
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    //    func recognizedHandler(request: VNRequest, error: Error?) -> [String] {
    //        guard let observations =
    //                request.results as? [VNRecognizedTextObservation] else {
    //            return []
    //        }
    //        let recognizedStrings = observations.compactMap { observation in
    //            // Return the string of the top VNRecognizedText instance.
    //            return observation.topCandidates(1).first?.string
    //        }
    //
    //        // Process the recognized strings.
    //        processResults(recognizedStrings)
    //    }
    
    public func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
        print("Changed")
        DispatchQueue.global(qos: .default).async {
            self.getText(image: image.cgImage!)
        }
    }
//      
//      public func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {
//          print("rfin")
//      }
}
