//
//  FaceDetector.swift
//  FaceVision
//
//  Created by Igor K on 6/7/17.
//  Copyright © 2017 Igor K. All rights reserved.
//

import UIKit
import Vision
import CoreImage

class FaceDetector {
    
    func translateImages(for referenceDotImage: UIImage,
                         floatingDotImage: UIImage,
                         originalImage: UIImage,
                         complete: @escaping (UIImage) -> Void) {
        let translationRequest = VNTranslationalImageRegistrationRequest.init(targetedCGImage: referenceDotImage.cgImage!) { (request, error) in
            var alignmentTransform: CGAffineTransform!
            if let results = request.results as? [VNImageTranslationAlignmentObservation] {
                results.forEach { result in
                    alignmentTransform = result.alignmentTransform
                    let testTransform = CGAffineTransform(a: 1.05225372, b: -0.26685286, c: 0.26685286, d: 1.05225372, tx: 16.64849909, ty:30.91795823 )
                    let newImage = UIImage(ciImage: CIImage(cgImage: originalImage.cgImage!).transformed(by: testTransform))
                    complete(newImage)
                    print(alignmentTransform)
                }
            }
        }
        let vnImage = VNSequenceRequestHandler()
        try? vnImage.perform([translationRequest], on: CIImage(cgImage: floatingDotImage.cgImage!))
    }
    
    open func highlightLips(for source: UIImage, complete: @escaping (UIImage, VNFaceLandmarks2D?) -> Void) {
        var resultImage = source
        var retLandmarks: VNFaceLandmarks2D? = nil
        let detectFaceRequest = VNDetectFaceLandmarksRequest { (request, error) in
            if error == nil {
                if let results = request.results as? [VNFaceObservation] {
                    print("Found \(results.count) faces")
                    
                    for faceObservation in results {
                        guard let landmarks = faceObservation.landmarks else {
                            continue
                        }
                        let boundingRect = faceObservation.boundingBox
                        resultImage = self.drawLipsOnImage(source: resultImage,
                                                       boundingRect: boundingRect,
                                                       faceLandmarkRegions: [landmarks.outerLips!])
                        retLandmarks = landmarks
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
            complete(resultImage, retLandmarks)
        }
        
        let vnImage = VNImageRequestHandler(cgImage: source.cgImage!, options: [:])
        try? vnImage.perform([detectFaceRequest])
    }
    
    open func highlightFaces(for source: UIImage, complete: @escaping (UIImage, VNFaceLandmarks2D?) -> Void) {
        var resultImage = source
        var retLandmarks: VNFaceLandmarks2D? = nil
        let detectFaceRequest = VNDetectFaceLandmarksRequest { (request, error) in
            if error == nil {
                if let results = request.results as? [VNFaceObservation] {
                    print("Found \(results.count) faces")
                    
                    for faceObservation in results {
                        guard let landmarks = faceObservation.landmarks else {
                            continue
                        }
                        let boundingRect = faceObservation.boundingBox
                        resultImage = self.drawOnImage(source: resultImage,
                                                  boundingRect: boundingRect,
                                                  faceLandmarkRegions: [landmarks.allPoints!])
                        retLandmarks = landmarks
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
            complete(resultImage, retLandmarks)
        }
        
        let vnImage = VNImageRequestHandler(cgImage: source.cgImage!, options: [:])
        try? vnImage.perform([detectFaceRequest])
    }
    
    func drawLipsOnImage(source: UIImage,
                         boundingRect: CGRect,
                         faceLandmarkRegions: [VNFaceLandmarkRegion2D]) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(source.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: source.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.colorBurn)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        let rectWidth = source.size.width * boundingRect.size.width
        let rectHeight = source.size.height * boundingRect.size.height
        
        //draw image
                let rect = CGRect(x: 0, y:0, width: source.size.width, height: source.size.height)
                context.draw(source.cgImage!, in: rect)
        
        
       
        //draw overlay
        let fillColor = UIColor.red
        fillColor.setStroke()
        fillColor.setFill()
        
        for faceLandmarkRegion in faceLandmarkRegions {
            var points: [CGPoint] = []
            for i in 0..<faceLandmarkRegion.pointCount {
                let point = faceLandmarkRegion.point(at: i)
                let p = CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
                points.append(p)
            }
            points.append(CGPoint(x: CGFloat(points[0].x), y: CGFloat(points[0].y)))
            let mappedPoints = points.map { CGPoint(x: boundingRect.origin.x * source.size.width + $0.x * rectWidth, y: boundingRect.origin.y * source.size.height + $0.y * rectHeight) }
            context.addLines(between: mappedPoints)
            context.drawPath(using: CGPathDrawingMode.fillStroke)
        }
        
        let coloredImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return coloredImg
    }
    
    fileprivate func drawOnImage(source: UIImage,
                                 boundingRect: CGRect,
                                 faceLandmarkRegions: [VNFaceLandmarkRegion2D]) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(source.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: source.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.colorBurn)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        let rectWidth = source.size.width * boundingRect.size.width
        let rectHeight = source.size.height * boundingRect.size.height
        
        //draw image
//        let rect = CGRect(x: 0, y:0, width: source.size.width, height: source.size.height)
//        context.draw(source.cgImage!, in: rect)
//        
//        
        //draw bound rect
//        var fillColor = UIColor.green
//        fillColor.setStroke()
//        context.addRect(CGRect(x: boundingRect.origin.x * source.size.width, y:boundingRect.origin.y * source.size.height, width: rectWidth, height: rectHeight))
//        context.drawPath(using: CGPathDrawingMode.stroke)
//
        //draw overlay
        let fillColor = UIColor.red
        fillColor.setStroke()
        context.setLineWidth(2.0)
        let count = faceLandmarkRegions.first!.pointCount
        var points: [CGPoint] = []
        for i in 0..<count {
            let point = faceLandmarkRegions.first!.point(at: i);
            let p = CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
            points.append(p)
        }
        
        context.addRects(points.map {
            return CGRect(x: boundingRect.origin.x * source.size.width + $0.x * rectWidth, y: boundingRect.origin.y * source.size.height + $0.y * rectHeight, width: 2, height: 2)
        })
        context.drawPath(using: .fillStroke)

        
//        faceLandmarkRegions.first?.points.map({ (point) -> CGRect in
//            CGRect(x: CGFloat(point.x), y: CGFloat(point.y), width: 2, height: 2);
//        })
//        for faceLandmarkRegion in faceLandmarkRegions {
//            var points: [CGPoint] = []
//            for i in 0..<faceLandmarkRegion.pointCount {
//                let point = faceLandmarkRegion.point(at: i)
//                let p = CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
//                points.append(p)
//            }
//            let mappedPoints = points.map { CGPoint(x: boundingRect.origin.x * source.size.width + $0.x * rectWidth, y: boundingRect.origin.y * source.size.height + $0.y * rectHeight) }
//            context.addLines(between: mappedPoints)
//            context.drawPath(using: CGPathDrawingMode.stroke)
//        }
//
        let coloredImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return coloredImg
//        return UIImage(cgImage: coloredImg.cgImage!.cropping(to: CGRect(x: boundingRect.origin.x * source.size.width, y: boundingRect.origin.y * source.size.height, width: boundingRect.width*source.size.width, height: boundingRect.height*source.size.height))!)
    }
}
