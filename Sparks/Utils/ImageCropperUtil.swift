//
//  ImageCropperUtil.swift
//  Sparks
//
//  Created by George Vashakidze on 6/7/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import TOCropViewController

protocol ImageCropperUtilDelegate: class {
    func didCropImage(image: UIImage)
}

class ImageCropperUtil: NSObject {

    private let imagePicker = UIImagePickerController()
    private weak var viewController: UIViewController!
    weak var delegate: ImageCropperUtilDelegate?

    init( viewController: UIViewController ) {
        self.viewController = viewController
    }

    private func showCropper(delegate: TOCropViewControllerDelegate, image: UIImage, isRectangle: Bool = true) {

        let style: TOCropViewCroppingStyle = isRectangle ? TOCropViewCroppingStyle.default : TOCropViewCroppingStyle.circular
        let cropController = TOCropViewController(croppingStyle: style, image: image)
        cropController.delegate = delegate

        if isRectangle {
            cropController.aspectRatioPreset = .presetCustom //Set the initial aspect ratio as a square
            cropController.customAspectRatio = CGSize(width: 288, height: 288)
        }

        cropController.aspectRatioLockEnabled = true // The crop box is locked to the aspect ratio and can't be resized away from it
        cropController.resetAspectRatioEnabled = false // When tapping 'reset', the aspect ratio will NOT be reset back to default

        // -- Uncomment this line of code to place the toolbar at the top of the view controller --
        // cropController.toolbarPosition = TOCropViewControllerToolbarPositionTop

        self.viewController.present(cropController, animated: true, completion: nil)

        if let items = cropController.toolbarItems {
            items[0].title = "Save"
            items[1].title = "Cancel"
            cropController.setToolbarItems(items, animated: false)
        }

    }

    private func onTakeAction() {
        self.imagePicker.sourceType = .camera
        self.imagePicker.cameraDevice = .front
        self.viewController.present(self.imagePicker, animated: true, completion: nil)
    }
    
    private func openGallery() {
        self.imagePicker.sourceType = .photoLibrary
        self.viewController.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func showImagePicker(otherActions: [UIAlertAction]? = nil, title: String) {
        
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = false
        var actions = [UIAlertAction]()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
        })
        
        actions.append(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let takePhotoAction = UIAlertAction(title: "Take a Photo", style: .default, handler: {[weak self] (action) in
                self?.onTakeAction()
            })
            actions.append(takePhotoAction)
        }
        
        let chooseFromGalleryAction = UIAlertAction(title: "Pick from Camera Roll", style: .default, handler: {[weak self] (action) in
            self?.openGallery()
        })
        
        actions.append(chooseFromGalleryAction)
        
        if let otherActions = otherActions {
            actions.append(contentsOf: otherActions)
        }
        self.viewController.showActionSheetWith(actions: actions, title: title)
    }
}

extension ImageCropperUtil: TOCropViewControllerDelegate {

    func newImageFromImage(sourceImage: UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth

        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor

        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        self.delegate?.didCropImage(
            image: self.newImageFromImage(
                sourceImage: image,
                scaledToWidth: 340
            )
        )
        cropViewController.dismiss(animated: true, completion: nil)
    }

    func cropViewController(_ cropViewController: TOCropViewController, didCropToCircularImage image: UIImage, with cropRect: CGRect, angle: Int) {
        self.delegate?.didCropImage(
            image: newImageFromImage(
                sourceImage: image,
                scaledToWidth: 128
            )
        )
        cropViewController.dismiss(animated: true, completion: nil)
    }

}

extension ImageCropperUtil: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.viewController.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        self.viewController.dismiss(animated: true, completion: {
            if let selectedImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.showCropper(delegate: self, image: selectedImage)
            }
        })
    }

}
