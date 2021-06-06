//
//  ViewController.swift
//  megha
//
//  Created by Karthikeyan K on 17/05/21.
//

import UIKit
import TensorFlowLite

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var labelOutput: UILabel!
    @IBOutlet weak var imageOutput: UIImageView!
    @IBOutlet weak var buttonRestart: UIButton!
    private var classifier: ImageClassifier?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ImageClassifier.newInstance { result in
            switch result {
            case let .success(classifier):
                self.classifier = classifier
            case .error(_):
                self.labelOutput.text = "Failed to initialize."
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            labelOutput.text = "No image found"
            return
        }
        
        imageOutput.image = image
        labelOutput.text = "Please wait... processing!"
        
        guard let classifier = self.classifier else { return }
        classifier.classify(image: image) { result in
            switch result {
            case let .success(classificationResult):
                self.labelOutput.text = classificationResult
            case .error(_):
                self.labelOutput.text = "Failed to classify drawing."
            }
        }
    }
    
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
        if(buttonRestart.isHidden) {
            buttonRestart.isHidden = false
        }
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
}
