//
//  ViewController.swift
//  WhatsApple-iOS
//
//  Created by gg on 3/24/19.
//  Copyright © 2019 gg. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreML
import ImageIO

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var imageView: UIImageView = UIImageView()
    var classificationLabel = UILabel()
    var appleDescription = UILabel()
    var appleName = UILabel()
    var appleImage: UIImageView = UIImageView()
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            // AppleDetector().model
            let model = try VNCoreMLModel(for: AppleDetector().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let view = UIView()
        view.backgroundColor = .white
        
        // classificationLabel
        classificationLabel.text = "<- Take a picture"
        classificationLabel.textColor = .black
        classificationLabel.numberOfLines = 4
        classificationLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(classificationLabel)
        
        // cameraButton
        let cameraButton:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.setImage(UIImage(named: "camera.png"), for: .normal)
        cameraButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        view.addSubview(cameraButton)
        
        // imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        // appleDescription
        appleDescription.text = ""
        appleDescription.numberOfLines = 4
        appleDescription.textColor = .black
        appleDescription.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appleDescription)
        
        // appleName
        appleName.text = ""
        appleName.font = appleName.font.withSize(24)
        appleName.textColor = .black
        appleName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appleName)
        
        // appleImage
        // appleImage.image = UIImage(named: "Fuji.jpg")
        appleImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appleImage)
        
        NSLayoutConstraint.activate([
            cameraButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            cameraButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            classificationLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            classificationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            appleDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            appleDescription.topAnchor.constraint(equalTo: cameraButton.topAnchor, constant: -125),
            appleDescription.heightAnchor.constraint(equalToConstant: 100),
            appleDescription.widthAnchor.constraint(equalToConstant: 200),
            appleName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            appleName.topAnchor.constraint(equalTo: appleDescription.topAnchor, constant: -50),
            appleImage.heightAnchor.constraint(equalToConstant: 100),
            appleImage.widthAnchor.constraint(equalToConstant: 100),
            appleImage.topAnchor.constraint(equalTo: classificationLabel.topAnchor, constant: -150),
            appleImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ])
        
        self.view = view
    }

    @objc func openCamera() {
        // Camera tests
        print("test")
        
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        // Image size tests
        print(image.size)
        
        imageView.image = image
        updateClassifications(for: image)
        
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.classificationLabel.text = "Nothing recognized."
            } else {
                // classifications.prefix(top classifications)
                let topClassifications = classifications.prefix(3)
                let descriptions = topClassifications.map { classification in
                    // Formatting (significant figures, etc)
                    return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                self.classificationLabel.text = "Classification:\n" +  descriptions.joined(separator: "\n")
                var classString = "Classification:\n" +  descriptions.joined(separator: "\n")
                var classArray = classString.components(separatedBy: " ")
                if classArray[3] == "Apple" {
                    self.appleName.text = "Apple Logo"
                    self.appleDescription.text = "The Apple Logo!"
                    self.appleImage.image = UIImage(named: "AppleLogo.png")
                } else if classArray[3] == "Golden" {
                    self.appleName.text = "Golden Delicious"
                    self.appleDescription.text = "A yellow apple, popular in the United States."
                    self.appleImage.image = UIImage(named: "Golden Delicious.jpg")
                } else if classArray[3] == "Fuji\n" {
                    self.appleName.text = "Fuji"
                    self.appleDescription.text = "An apple hybrid, developed in Japan."
                    self.appleImage.image = UIImage(named: "Fuji.jpg")
                } else if classArray[3] == "Braeburn\n" {
                    self.appleName.text = "Braeburn"
                    self.appleDescription.text = "A red/orange apple originating from New Zealand."
                    self.appleImage.image = UIImage(named: "Braeburn.jpg")
                } else if classArray[3] == "Crispin\n" {
                    self.appleName.text = "Crispin"
                    self.appleDescription.text = "A green Japanese apple also known as Mutsu."
                    self.appleImage.image = UIImage(named: "Crispin.png")
                } else if classArray[3] == "Gala\n" {
                    self.appleName.text = "Gala"
                    self.appleDescription.text = "A red apple that recently became the most produced apple in the United States."
                    self.appleImage.image = UIImage(named: "Gala.jpg")
                } else if classArray[3] == "Granny" {
                    self.appleName.text = "Granny Smith"
                    self.appleDescription.text = "A green apple originating from Australia."
                    self.appleImage.image = UIImage(named: "Granny Smith.jpg")
                } else if classArray[3] == "Honeycrisp\n" {
                    self.appleName.text = "Honeycrisp"
                    self.appleDescription.text = "An apple cultivar developed in Minnesota."
                    self.appleImage.image = UIImage(named: "Honeycrisp.jpg")
                } else if classArray[3] == "McIntosh\n" {
                    self.appleName.text = "McIntosh"
                    self.appleDescription.text = "A red apple, the national apple of Canada."
                    self.appleImage.image = UIImage(named: "McIntosh.jpg")
                } else if classArray[3] == "Pink" {
                    self.appleName.text = "Pink Lady"
                    self.appleDescription.text = "A red apple, also known as Cripps Pink."
                    self.appleImage.image = UIImage(named: "Pink Lady.jpg")
                } else if classArray[3] == "Red" {
                    self.appleName.text = "Red Delicious"
                    self.appleDescription.text = "A red apple, popular in the United States."
                    self.appleImage.image = UIImage(named: "Red Delicious.jpg")
                }
            }
        }
    }
    
    func updateClassifications(for image: UIImage) {
        classificationLabel.text = "Classifying..."
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        print(orientation)
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
}

// Image Orientation (CGImagePropertyOrientation+UIImageOrientation.swift)
// Apache License 2.0, Copyright 2018 Apple Inc.
import UIKit
import ImageIO

extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}




