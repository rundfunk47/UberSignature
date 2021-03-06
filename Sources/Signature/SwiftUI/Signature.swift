//
//  Signature.swift
//  UberSignature
//
//  Created by Narek Mailian on 2020-07-14.
//  Copyright © 2020 Uber. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, *)
public struct Signature: UIViewRepresentable {
    @Binding var image: UIImage?
    private let color: UIColor

    public func updateUIView(_ uiView: SignatureDrawingView, context: Context) {
        if uiView.partialSignatureImage != image {
            uiView.setImage(image: self.image)
        }
    }

    public func makeUIView(context: Context) -> SignatureDrawingView {
        let view = SignatureDrawingView(frame: .zero, image: image)
        view.delegate = context.coordinator
        view.signatureColor = color
        return view
    }

    fileprivate init(image: Binding<UIImage?>, color: UIColor) {
        self._image = image
        self.color = color
    }

    public func makeCoordinator() -> SignatureDelegate {
        return SignatureDelegate(image: $image)
    }

    public init(image: Binding<UIImage?>) {
        self._image = image
        self.color = .black
    }
}

@available(iOS 13.0, *)
public class SignatureDelegate: SignatureDrawingViewDelegate {
    public func signatureDrawingViewDidChange(view: UIImage?) {
        self.image = view
    }

    @Binding var image: UIImage?

    init(image: Binding<UIImage?>) {
        self._image = image
    }
}
