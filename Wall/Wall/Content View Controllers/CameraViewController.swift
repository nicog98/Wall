//
//  CameraViewController.swift
//  Wall
//
//  On iPhone: allows users to select photos from their libraries,
//  or take photos with the built-in camera. Allows users to save captured photos
//  in their library.
//
//  APIs Used:
//      UIImagePickerController 2 - Used to both take pictures from camera and choose photos from library
//      PHPhotoLibrary 1 - Store captured photos in library
//
//  Created by Nicolai Garcia on 11/28/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

protocol CameraViewControllerDelegate: class {
    func choseImage(_ imageURL: URL, _ aspectRatio: CGFloat)
    func choseMovie(_ movieURL: URL)
    func capturedPhoto(_ imageData: Data, _ aspectRatio: CGFloat)
}

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: UIImagePickerController
    
    let picker = UIImagePickerController()
    
    var delegate: CameraViewControllerDelegate?

    @IBAction func photo(_ sender: UIButton) {
        if (UIImagePickerController .isSourceTypeAvailable(.camera)) {
            picker.allowsEditing = false
            picker.sourceType = .camera
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            present(picker, animated: true)
        }
    }
    
    @IBAction func library(_ sender: UIButton) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true)
    }
    
    @IBOutlet weak var libraryButton: UIButton!
    
    // MARK: Delegates
    
    func addAsset(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (success, error) in
            if !success {
                print("Error adding image to photo library")
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        var aspectRatio: CGFloat?
        if let chosenImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
            aspectRatio = chosenImage.size.height / chosenImage.size.width
            if (picker.sourceType == .camera) {
                addAsset(image: chosenImage)
                delegate?.capturedPhoto(UIImageJPEGRepresentation(chosenImage, 1.0)!, aspectRatio!)
                dismiss(animated: true, completion: {
                    self.close(nil)
                })
            }
        }
        if let chosenImageURL = info[UIImagePickerControllerImageURL] as? URL {
            delegate?.choseImage(chosenImageURL, aspectRatio!)
            dismiss(animated: true, completion: ({
                self.close(nil)
            }))
        } else if let chosenMovieURL = info[UIImagePickerControllerMediaURL] as? URL {
            delegate?.choseMovie(chosenMovieURL)
            picker.presentingViewController?.dismiss(animated: true, completion: ({
                self.close(nil)
            }))
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(closeSwipe(_:)))
        swipe.direction = .down
        self.view.addGestureRecognizer(swipe)
    }
    
    // MARK: Close
    
    @IBAction func close(_ sender: UIBarButtonItem?) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func closeSwipe(_ sender: UISwipeGestureRecognizer) {
        close(nil)
    }
    
    private var textFont: UIFont {
        return UIFontMetrics(forTextStyle: .headline).scaledFont(for:
            UIFont.preferredFont(forTextStyle: .headline)).withSize(CameraViewController.constants.fontSize)
    }

}

extension CameraViewController {
    private struct constants {
        static let fontSize: CGFloat = 30.0
    }
}
