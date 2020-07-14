//
//  ContentView.swift
//  ExampleSwiftUI
//
//  Created by Narek Mailian on 2020-07-14.
//  Copyright © 2020 Uber. All rights reserved.
//

import SwiftUI
import UberSignature

extension UIImage {
    func imageWith(newSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let image = renderer.image { _ in
            self.draw(in: CGRect.init(origin: CGPoint.zero, size: newSize))
        }

        return image.withRenderingMode(self.renderingMode)
    }
}

struct ContentView: View {
    @State var image: UIImage?

    var body: some View {
        VStack {
            Text("Hello, World!")
            Signature(image: $image)
                .background(Color.blue)
                .frame(width: 300, height: 300, alignment: .center)
            Button(action: {
                let uiAlertControl = UIAlertController(
                    title: "Signature",
                    message: "This is what you've drawn!",
                    preferredStyle: .alert
                )

                let uiImageAlertAction = UIAlertAction(
                    title: "",
                    style: .default,
                    handler: nil
                )

                let maxsize = CGSize(width: 100, height: 100)

                if let resizedImage = self.$image.wrappedValue?.imageWith(newSize: maxsize) {
                    uiImageAlertAction.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
                    uiAlertControl.addAction(uiImageAlertAction)

                    uiAlertControl.addAction(UIAlertAction(title: "Thanks!", style: .cancel, handler: nil))
                } else {
                    uiAlertControl.addAction(UIAlertAction(title: "Nope!", style: .cancel, handler: nil))
                }

                UIApplication.shared.keyWindow?.rootViewController?.present(uiAlertControl, animated: true, completion: nil)
            }) {
                Text("OK")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
