//
//  BoundingBoxView.swift
//  MLModelCamera
//
//  Created by Shuichi Tsutsumi on 2020/03/22.
//  Copyright © 2020 Shuichi Tsutsumi. All rights reserved.
//

import UIKit
import Vision
import AVFoundation.AVUtilities

class BoundingBoxView: UIView {
    private let strokeWidth: CGFloat = 2
    
    private var imageRect: CGRect = CGRect.zero
    var observations: [VNDetectedObjectObservation]!
    
    func updateSize(for imageSize: CGSize) {
        imageRect = AVMakeRect(aspectRatio: imageSize, insideRect: self.bounds)
    }
    
    override func draw(_ rect: CGRect) {
        guard observations != nil && observations.count > 0 else { return }
        subviews.forEach({ $0.removeFromSuperview() })

        let context = UIGraphicsGetCurrentContext()!
        
        for i in 0..<observations.count {
            let observation = observations[i]
            var color = UIColor(hue: CGFloat(i) / CGFloat(observations.count), saturation: 1, brightness: 1, alpha: 1)
            if #available(iOS 12.0, *), let recognizedObjectObservation = observation as? VNRecognizedObjectObservation {
                let firstLabelHash = recognizedObjectObservation.labels.first?.identifier.hashValue ?? 0.hashValue
                color = UIColor(hue: (CGFloat(firstLabelHash % 256) / 512.0) + 1.0, saturation: 1, brightness: 1, alpha: 1)
            }

            let rect = drawBoundingBox(context: context, observation: observation, color: color)
            
            if #available(iOS 12.0, *), let recognizedObjectObservation = observation as? VNRecognizedObjectObservation {
                addLabel(on: rect, observation: recognizedObjectObservation, color: color)
            }
        }
    }
    
    private func drawBoundingBox(context: CGContext, observation: VNDetectedObjectObservation, color: UIColor) -> CGRect {
        let convertedRect = VNImageRectForNormalizedRect(observation.boundingBox, Int(imageRect.width), Int(imageRect.height))
        let x = convertedRect.minX + imageRect.minX
        let y = (imageRect.height - convertedRect.maxY) + imageRect.minY
        let rect = CGRect(origin: CGPoint(x: x, y: y), size: convertedRect.size)
        
        context.setStrokeColor(color.cgColor)
        
        context.setLineWidth(strokeWidth)
        context.stroke(rect)
        
        return rect
    }

    @available(iOS 12.0, *)
    private func addLabel(on rect: CGRect, observation: VNRecognizedObjectObservation, color: UIColor) {
        guard let firstLabel = observation.labels.first?.identifier else { return }
                
        let label = UILabel(frame: .zero)
        label.text = firstLabel
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = UIColor.black
        label.backgroundColor = color
        label.sizeToFit()
        label.frame = CGRect(x: rect.origin.x-strokeWidth/2,
                             y: rect.origin.y - label.frame.height,
                             width: label.frame.width,
                             height: label.frame.height)
        addSubview(label)
    }
}
