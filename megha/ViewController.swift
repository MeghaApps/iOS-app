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
    private var result: Result?
    
    private var modelDataHandler: ModelDataHandler? =
        ModelDataHandler(modelFileInfo: MobileNet.modelInfo, labelsFileInfo: MobileNet.labelsInfo)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard modelDataHandler != nil else {
              fatalError("Model set up failed")
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
        
        guard let buffer = CVImageBuffer.buffer(from: image) else {
              return
        }
        
        result = modelDataHandler?.runModel(onFrame: buffer)
        
        //labelOutput.text = String(describing: result?.inferences)
        labelOutput.text = "The cloud is of the type \(getFullLabelText(label: (result?.inferences[0].label)!)) with a probability of \((result?.inferences[0].confidence)! * 100).\n\(getLabelPrediction(label: (result?.inferences[0].label)!))"
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
    
    func getFullLabelText(label: String) -> String {
        switch label {
        case "Ci":
            return "Cirrus"
        case "Cs":
            return "Cirrostratus"
        case "Cc":
            return "Cirrocumulus"
        case "Ac":
            return "Altocumulus"
        case "As":
            return "Altostratus"
        case "Cu":
            return "Cumulus"
        case "Cb":
            return "Cumulonimbus"
        case "Ns":
            return "Nimbostratus"
        case "Sc":
            return "Stratocumulus"
        case "St":
            return "Stratus"
        case "Ct":
            return "Contrail"
        default:
            return "error"
        }
    }
    
    func getLabelPrediction(label: String) -> String {
        switch label {
        case "Ci":
            return "A warm front is approaching."
        case "Cs":
            return "A storm is coming."
        case "Cc":
            return "The weather is about to change!"
        case "Ac":
            return "Rain is coming soon!"
        case "As":
            return "Rain, incoming."
        case "Cu":
            return "Fair weather!"
        case "Cb":
            return "Thunderstorms may be due."
        case "Ns":
            return "Rain / Fog incoming."
        case "Sc":
            return "Bad weather incoming."
        case "St":
            return "Light rain."
        case "Ct":
            return "Airplanes!"
        default:
            return "error"
        }
    }
}
