//
//  ImageExtension.swift
//  AndroidQuality
//
//  Created by Michael Lema on 11/8/18.
//  Copyright © 2018 Michael Lema. All rights reserved.
//

import UIKit

extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let newImageSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        let frame = CGRect(origin: .zero, size: newImageSize)
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        // Begin drawing image
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
