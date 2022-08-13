//
//  ViewController.swift
//  NetworkManagerSwift
//
//  Created by Santhosh K on 11/08/22.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var imgV: UIImageView!
    
    let picker = UIImagePickerController()
    var selectMediaType = String()
    var selectedThumnailImage: UIImage? = UIImage()
    var uploadImage:UIImage? = nil
    var videoPath: URL? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.callApi()
    }

    
    @IBAction func cameraBtnAcion(_ sender: UIButton) {
        self.cameraPopUp(withtitle: "MyCamera",buttonType: "")
    }
}

//MARK:- Sample api call
extension ViewController {
    func callApi() {
        //smapleAPI
        let urlStr = ""
        let params = [String:Any]()
        Requester.sharedHelper()?.callGetWebService(urlStr, withHttpType: "POST", withParams: params, isTokenEnabled: false, withCompletionHandler: { responseJson, statusRes, messageRes, statusCode in
            print(responseJson)
        })
    }
}


//MARK:- UIImagePickerControllerDelegate methods
//ImagePicker

extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate {
    
    func cameraPopUp(withtitle:String,buttonType:String)  {
        
        let myAlert = UIAlertController(title: withtitle, message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.picker.sourceType = .camera
                self.picker.delegate = self
                self.picker.allowsEditing = true
                if self.selectMediaType == "videoooooo" {
                    self.picker.mediaTypes =  ["public.movie"] }
                else{
                    self.selectMediaType = "image"
                    self.picker.mediaTypes =  ["public.image"] }
                self.present(self.picker, animated: true, completion: nil)
            }
        }
        
        let cameraRollAction = UIAlertAction(title: "Gallery", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                self.picker.sourceType = .photoLibrary
                self.picker.delegate = self
                self.picker.allowsEditing = true
                if self.selectMediaType == "videoooooo" {
                    self.picker.mediaTypes =  ["public.movie"] }
                else{
                    self.selectMediaType = "image"
                    self.picker.mediaTypes =  ["public.image"] }
                self.present(self.picker, animated: true, completion: {      self.picker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .white
                })
            }
        }
        let videoRollAction = UIAlertAction(title: "Video/camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.picker.sourceType = .camera
                self.picker.delegate = self
                self.picker.allowsEditing = true
                self.picker.mediaTypes =  ["public.movie"]
                self.selectMediaType = "video"
                self.present(self.picker, animated: true, completion: nil)
            }
        }
        let videoFromGallery = UIAlertAction(title: "Video/Gallery", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                self.picker.sourceType = .photoLibrary
                self.picker.delegate = self
                self.picker.allowsEditing = true
                self.picker.mediaTypes =  ["public.movie"]
                self.selectMediaType = "video"
                self.present(self.picker, animated: true, completion: {      self.picker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .white
                })
            }
        }
        
        let CancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            self.selectMediaType = ""
            
            
            self.dismiss(animated: false, completion: {
            })
        }
        
        
        myAlert.addAction(cameraAction)
        myAlert.addAction(cameraRollAction)
        myAlert.addAction(videoRollAction)
        myAlert.addAction(videoFromGallery)
        myAlert.addAction(CancelAction)
        self.present(myAlert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.videoPath = nil
        self.uploadImage = nil
        
        if self.selectMediaType == "video" {
            if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                print(videoURL)
                selectedThumnailImage = videoURL.generateThumbnail()
                self.videoPath = videoURL
            }
        }
        else {
            var newImage = UIImage()
            if let possibleImage = info[.editedImage] as? UIImage {
                newImage = possibleImage
            } else if let possibleImage = info[.originalImage] as? UIImage {
                newImage = possibleImage
            } else {
                return
            }
            
            self.uploadImage = newImage
            
        }
        self.uploadMedia()
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // DispatchQueue.main.async { self.maskView.removeFromSuperview()}
        dismiss(animated: true, completion: nil)
    }
    
    
    func uploadMedia() {
        self.imgV.image = self.selectedThumnailImage
        print(self.videoPath!)
        let urlStr = "https://api.cuddloo.com/userPhotoVideo/signup/44"
        
        var mediaParams = [[String:Any]]()
        
        mediaParams = [
            ["key":"video[]", "value":self.videoPath!,"type":"video/mov", "fileName":"\(UInt8.random)_upload.mov"],
            ["key":"thumbnail_image[]", "value":self.selectedThumnailImage!,"type":"image/jpg", "fileName":"\(UInt8.random)_image.jpg"]]
        let params:[String:Any] = ["completed_page_no":5]
        
        UserDefaults.standard.loginToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjQ0LCJpYXQiOjE2NjAzNzEyNzYsImV4cCI6MTY2Mjk2MzI3NiwidHlwZSI6InJlZnJlc2hfdG9rZW4ifQ._k_MVD2Ex_OII2k6jdbJJAreSEsDuf6vhHpI09JMALE"
        
        Requester.sharedHelper()?.callImageVideoUpload(mainUrl: urlStr, withHttpType: "POST", mediaParams: mediaParams, withParams: params, isTokenEnabled: true, withCompletionHandler: { resJson, statusR, messageR, statusCode in
            print(resJson)
        })
    }
}




extension URL {
    func generateThumbnail() -> UIImage {
        let asset = AVAsset(url: self)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = 0
        var thumbnail = UIImage()
        if let imageRef = try? generator.copyCGImage(at: time, actualTime: nil) {
            thumbnail = UIImage(cgImage: imageRef)
        }
        return thumbnail
    }
}
