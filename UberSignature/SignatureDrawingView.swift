/**
 Copyright (c) 2017 Uber Technologies, Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit

public protocol SignatureDrawingViewDelegate: class {
    func signatureDrawingViewDidChange(view: SignatureDrawingView)
}

/**
 A view controller that allows the user to draw a signature and provides additional functionality.
 */
public class SignatureDrawingView: UIView {
   
    /**
     Initializer
     - parameter image: An optional starting image for the signature.
     */
    public init(frame: CGRect, image: UIImage? = nil) {
        self.presetImage = image

        super.init(frame: frame)

        self.backgroundColor = UIColor.clear
        self.addSubview(imageView)

        self.layer.addSublayer(bezierPathLayer)
        self.layer.masksToBounds = true

        // Constraints

        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            NSLayoutConstraint.init(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: imageView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: imageView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),
            ])

        if let image = image {
            self.layoutIfNeeded()
            model.addImageToSignature(image)
            updateViewFromModel()
            self.presetImage = nil
        }
    }

    /// Use init(image:) instead.
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Returns an image of the signature (with a transparent background).
    public var fullSignatureImage: UIImage? {
        if self.bezierPathLayer.path == nil && self.imageView.image == nil {
            return nil
        }
        return model.fullSignatureImage
    }
    
    /**
     The color of the signature.
     Defaults to black.
     */
    public var signatureColor: UIColor {
        get {
            return model.signatureColor
        }
        set(color) {
            model.signatureColor = color
            bezierPathLayer.strokeColor = color.cgColor
            bezierPathLayer.fillColor = color.cgColor
        }
    }

    /// Delegate for callbacks.
    public weak var delegate: SignatureDrawingViewDelegate?
    
    /// Resets the signature.
    public func reset() {
        model.reset()
        updateViewFromModel()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        model.imageSize = self.bounds.size
        updateViewFromModel()
    }
    
    // MARK: UIResponder
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        updateModel(withTouches: touches, shouldEndContinousLine: true)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        updateModel(withTouches: touches, shouldEndContinousLine: false)
    }
    
    // MARK: Private
    
    private let model = SignatureDrawingModelAsync()
    
    private lazy var bezierPathLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = signatureColor.cgColor
        layer.fillColor = signatureColor.cgColor
        
        return layer
    }()

    private var imageView = UIImageView()
    private var presetImage: UIImage?
    
    private func updateModel(withTouches touches: Set<UITouch>, shouldEndContinousLine: Bool) {
        guard let touchPoint = touches.touchPoint else {
            return
        }
        
        if shouldEndContinousLine {
            model.asyncEndContinuousLine()
        }
        model.asyncUpdate(withPoint: touchPoint)
        updateViewFromModel()
    }
    
    private func updateViewFromModel() {
        model.asyncGetOutput { (output) in
            if self.imageView.image != output.signatureImage {
                self.imageView.image = output.signatureImage
            }
            if self.bezierPathLayer.path != output.temporarySignatureBezierPath?.cgPath {
                self.bezierPathLayer.path = output.temporarySignatureBezierPath?.cgPath
            }

            self.delegate?.signatureDrawingViewDidChange(view: self)
        }
    }
}

extension Set where Element == UITouch {
    var touchPoint: CGPoint? {
        let touch = first
        return touch?.location(in: touch?.view)
    }
}
