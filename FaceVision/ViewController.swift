//
//  ViewController.swift
//  FaceVision
//
//  Created by Igor K on 6/7/17.
//  Copyright © 2017 Igor K. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var faceDetector :FaceDetector = {
        return FaceDetector()
    }()
    fileprivate var selectedImage: UIImage! {
        didSet {
//            imageView?.image = selectedImage
//            let faceDetector = FaceDetector()
//            DispatchQueue.global().async {
//                faceDetector.highlightFaces(for: self.selectedImage) { (resultImage) in
//                    DispatchQueue.main.async {
//                        self.imageView?.image = resultImage
//                    }
//                }
//            }
        }
    }
    
    @IBOutlet weak var inputImage1: UIImageView!
    @IBOutlet weak var inputImage2: UIImageView!
    @IBOutlet weak var outputImage: UIImageView!

    var img1Landmark: VNFaceLandmarks2D!
    var img2Landmark: VNFaceLandmarks2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addImages()
        
    }
    
    func addImages() {
        guard let image1 = UIImage(named: "tim"),
            let image2 = UIImage(named: "Trump") else { return }
        
        self.inputImage1.image = image1
        self.inputImage2.image = image2

//        findFeatures(image1: image1, image2: image2) {
//            self.translateImage2ToImage1()
//        }
        addLipstick(image1: UIImage(named: "mvince")!, image2: UIImage(named: "patelkev")!, image3: UIImage(named: "jherron")!)
    }
    
    func addLipstick(image1: UIImage, image2: UIImage, image3: UIImage)  {
        let backgroudQueue = DispatchQueue.global()
        self.inputImage1.image = image1
        self.inputImage2.image = image2
        self.outputImage.image = image3
        
        backgroudQueue.async {
            self.faceDetector.highlightFaces(for: image1, complete: { (resImage, landmarks) in
                DispatchQueue.main.async {
                    self.inputImage1.image = resImage
                }
            })
        }
        backgroudQueue.async {
            self.faceDetector.highlightFaces(for: image2, complete: { (resImage, landmarks) in
                DispatchQueue.main.async {
                    self.inputImage2.image = resImage
                }
            })
        }
        backgroudQueue.async {
            self.faceDetector.highlightFaces(for: image3, complete: { (resImage, landmarks) in
                DispatchQueue.main.async {
                    self.outputImage.image = resImage
                }
            })
        }
    }
    
    func findFeatures(image1: UIImage, image2: UIImage, completion:@escaping (() -> Void) ) {
        let dpGrp = DispatchGroup()
        let backgroudQueue = DispatchQueue.global()

        dpGrp.enter()
        backgroudQueue.async {
            self.faceDetector.highlightFaces(for: image1) { (highlightedImage, landmarks) in
                DispatchQueue.main.async {
                    self.inputImage1.image = highlightedImage
                    if let landmarks = landmarks {
                        self.img1Landmark = landmarks
                    }
                    dpGrp.leave()
                }
            }
        }
        
        dpGrp.enter()
        backgroudQueue.async {
            self.faceDetector.highlightFaces(for: image2) { (highlightedImage, landmarks) in
                DispatchQueue.main.async {
                    self.inputImage2.image = highlightedImage
                    if let landmarks = landmarks {
                        self.img2Landmark = landmarks
                    }
                    dpGrp.leave()
                }
            }
        }
        dpGrp.notify(queue: DispatchQueue.main, execute: completion)

    }
    
    func translateImage2ToImage1() {
        let originalImage = UIImage(named:"Trump")
        faceDetector.translateImages(for: self.inputImage1.image!, floatingDotImage: self.inputImage2.image!, originalImage: originalImage!) { (resultImage) in
            self.outputImage.image = resultImage
//            self.inputImage2.image = originalImage
//            self.inputImage1.image = UIImage.init(named: "kim")
        }
    }
}

