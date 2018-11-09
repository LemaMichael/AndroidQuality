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
import AVKit


class ViewController: UIViewController {
    
    var imagePickerController = UIImagePickerController()
    let videoPlayerViewController = AVPlayerViewController()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var videoView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    var compressedVideoData: NSData?
    
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
        if let image = imageView.image  {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else if let compressedVideoData = compressedVideoData {
            DispatchQueue.global(qos: .background).async {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/tempFile.mp4"
                DispatchQueue.main.async {
                    compressedVideoData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if let error = error {
                            print("Video was not saved: \(error.localizedDescription)")
                        }
                        print("Saved video!")
                    }
                }
            }
        } else {
            print("Image not saved!")
        }
    }
    
    fileprivate func playVideo(compressedURL: URL) {
        DispatchQueue.main.async {
            self.videoPlayerViewController.showsPlaybackControls = false
            self.videoPlayerViewController.player = AVPlayer(url: compressedURL)
            self.videoView.addSubview(self.videoPlayerViewController.view)
            self.videoPlayerViewController.view.frame = self.videoView.bounds
            self.videoPlayerViewController.player?.play()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:1.00, green:0.50, blue:0.31, alpha:1.00)
        view.addSubview(assetButton)
        view.addSubview(saveButton)
        view.addSubview(imageView)
        imageView.addSubview(videoView)
        imagePickerController.delegate = self
        setupViews()
    }
    
    fileprivate func setupViews() {
        saveButton.anchor(top: nil, bottom: view.layoutMarginsGuide.bottomAnchor, left: assetButton.leftAnchor, right: assetButton.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 200, height: 50)
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        assetButton.anchor(top: nil, bottom: saveButton.topAnchor, left: saveButton.leftAnchor, right: saveButton.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 50)
        
        imageView.anchor(top: view.layoutMarginsGuide.topAnchor, bottom: nil, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingBottom: 10, paddingLeft: 0, paddingRight: 0, width: 0, height: UIScreen.main.bounds.height / 2)
        
        videoView.anchor(top: imageView.topAnchor, bottom: imageView.bottomAnchor, left: imageView.leftAnchor, right: imageView.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            compressedVideoData = nil
            videoView.isHidden = true
            let newImage = image.resizeWithPercent(percentage: 0.02)
            imageView.image = newImage
            self.dismiss(animated: true, completion: nil)
        }
        else if let videoURL = info[.mediaURL] as? URL {
            videoView.isHidden = false
            print("Video selected.")
            print("videoURL:\(String(describing: videoURL))")
            guard let videoData = NSData(contentsOf: videoURL) else { return }
            print("File size before compression: \(Double(videoData.length / 1048576)) mb")
            let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".MP4")
            compressVideo(inputURL: videoURL, outputURL: compressedURL) { (session) in
                
                switch session.status {
                case .completed:
                    guard let compressedData = NSData(contentsOf: compressedURL) else { return }
                    self.compressedVideoData = compressedData
                    print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                    self.playVideo(compressedURL: compressedURL)
                    self.dismiss(animated: true, completion: nil)
                default:
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ session: AVAssetExportSession)-> Void)
    {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetLowQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
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

