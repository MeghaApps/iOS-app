//
//  ImageClassifier.swift
//  megha
//
//  Created by Karthikeyan K on 18/05/21.
//

import CoreImage
import UIKit
import TensorFlowLite

class ImageClassifier {
    
    private var interpreter: Interpreter
    private var inputImageWidth: Int
    private var inputImageHeight: Int
    
    static func newInstance(completion: @escaping ((Result<ImageClassifier>) -> ())) {
        DispatchQueue.global(qos: .background).async {
            
            guard let modelPath = Bundle.main.path(
                forResource: Constant.modelFilename,
                ofType: Constant.modelFileExtension
            ) else {
                print("Failed to load the model file with name: \(Constant.modelFilename).")
                DispatchQueue.main.async {
                    completion(.error(InitializationError.invalidModel("\(Constant.modelFilename).\(Constant.modelFileExtension)")))
                }
                return
            }
            
            var options = Interpreter.Options()
            options.threadCount = 2
            
            do {
                let interpreter = try Interpreter(modelPath: modelPath, options: options)
                
                try interpreter.allocateTensors()
                
                let inputShape = try interpreter.input(at: 0).shape
                let inputImageWidth = inputShape.dimensions[1]
                let inputImageHeight = inputShape.dimensions[2]
                
                let classifier = ImageClassifier(
                    interpreter: interpreter,
                    inputImageWidth: inputImageWidth,
                    inputImageHeight: inputImageHeight
                )
                DispatchQueue.main.async {
                    completion(.success(classifier))
                }
            } catch let error {
                print("Failed to create the interpreter with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.error(InitializationError.internalError(error)))
                }
                return
            }
        }
    }
    
    fileprivate init(interpreter: Interpreter, inputImageWidth: Int, inputImageHeight: Int) {
        self.interpreter = interpreter
        self.inputImageWidth = inputImageWidth
        self.inputImageHeight = inputImageHeight
    }
    
    func classify(image: UIImage, completion: @escaping ((Result<String>) -> ())) {
        DispatchQueue.global(qos: .background).async {
            let outputTensor: Tensor
            do {
                guard let rgbData = image.scaledData(with: CGSize(width: self.inputImageWidth, height: self.inputImageHeight))
                else {
                    DispatchQueue.main.async {
                        completion(.error(ClassificationError.invalidImage))
                    }
                    print("Failed to convert the image buffer to RGB data.")
                    return
                }
                
                try self.interpreter.copy(rgbData, toInputAt: 0)
                
                try self.interpreter.invoke()
                
                outputTensor = try self.interpreter.output(at: 0)
            } catch let error {
                print("Failed to invoke the interpreter with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.error(ClassificationError.internalError(error)))
                }
                return
            }
            
            let results = outputTensor.data.toArray(type: Float32.self)
            let humanReadableResult = "Predicted: \(results)"
            
            DispatchQueue.main.async {
                completion(.success(humanReadableResult))
            }
        }
    }
}

enum Result<T> {
    case success(T)
    case error(Error)
}

enum InitializationError: Error {
    case invalidModel(String)
    case internalError(Error)
}

enum ClassificationError: Error {
    case invalidImage
    case internalError(Error)
}

private enum Constant {
    static let modelFilename = "model"
    static let modelFileExtension = "tflite"
}
