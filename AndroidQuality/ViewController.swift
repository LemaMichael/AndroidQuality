//
//  ViewController.swift
//  AndroidQuality
//
//  Created by Michael Lema on 11/8/18.
//  Copyright © 2018 Michael Lema. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

class ViewController: UIViewController {
    
    var imagePickerController = UIImagePickerController()
    
    
    lazy var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy var assetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitle("Upload Image/Video", for: .normal)
        button.addTarget(self, action: #selector(handleVideoButton), for: .touchUpInside)
        return button
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleVideoButton() {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.movie", kUTTypeImage as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleSave() {
        guard let image = imageView.image else {
            print("Image not saved!")
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:1.00, green:0.50, blue:0.31, alpha:1.00)
        view.addSubview(assetButton)
        view.addSubview(saveButton)
        view.addSubview(imageView)
        imagePickerController.delegate = self
        setupViews()
    }
    
    fileprivate func setupViews() {
        assetButton.anchor(top: nil, bottom: nil, left: nil, right: nil, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 200, height: 50)
        assetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        assetButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 1).isActive = true
        
        imageView.anchor(top: view.layoutMarginsGuide.topAnchor, bottom: assetButton.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingBottom: 10, paddingLeft: 0, paddingRight: 0, width: 0, height: 0)
        
        saveButton.anchor(top: assetButton.bottomAnchor, bottom: nil, left: assetButton.leftAnchor, right: assetButton.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL  else { return }
//        print("videoURL:\(String(describing: videoURL))")
//        let videoData = NSData(contentsOf: videoURL)
//
//        self.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            let newImage = image.resizeWithPercent(percentage: 0.02)
            imageView.image = newImage
        }
        else if let videoURL = info[.mediaURL] as? URL {
            //picker.videoQuality = UIImagePickerControllerQualityTypeLow
            print("Video selected.")
            print("videoURL:\(String(describing: videoURL))")

        }
        self.dismiss(animated: true, completion: nil)
    }

    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("Image saved!")
        }
    }
}

