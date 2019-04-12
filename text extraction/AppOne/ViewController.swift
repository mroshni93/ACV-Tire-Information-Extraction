//
//  ViewController.swift
//  AppOne
//
//  Created by Intern on 3/8/19.
//  Copyright © 2019 Intern. All rights reserved.
//

import UIKit
import Firebase
class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate ,URLSessionDelegate,URLSessionTaskDelegate,URLSessionDataDelegate{

    @IBOutlet weak var myImage: UIImageView!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var myTextDisplay: UITextField!
    
    @IBOutlet weak var selectPhoto: UIButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    
    let view1: UIView = {
        
        let view1 = UIView()
        
        view1.translatesAutoresizingMaskIntoConstraints = false
        
        view1.backgroundColor = UIColor.clear
        //view1.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        
        view1.layer.borderWidth = 4.0
        
        view1.layer.borderColor = UIColor.yellow.cgColor
        
        return view1
        
    }()
    
    
    
    @objc func handlePan(gesture: UIPanGestureRecognizer){
        
        let translation = gesture.translation(in: self.view)
            
            if (view1.frame.origin.x + translation.x >= 0) && (view1.frame.origin.y + translation.y >= 0) && (view1.frame.origin.x + translation.x <= 3*myImage.frame.width/4 ) && (view1.frame.origin.y + translation.y <= 3*myImage.frame.height/4)
            {
                view1.center = CGPoint(x:view1.center.x + translation.x,y:view1.center.y + translation.y)
                
            }
        
        gesture.setTranslation(CGPoint.zero, in: self.view)
        
        
    }
    
    
    @objc func handlePinch(gesture: UIPinchGestureRecognizer){
        
        let maxScale:CGFloat = 2.0
        let minScale:CGFloat = 0.5
        
        let currentScale = view1.frame.width/view1.bounds.size.width
        var newScale = gesture.scale
        if currentScale * gesture.scale < minScale {
            newScale = minScale / currentScale
        } else if currentScale * gesture.scale > maxScale {
            newScale = maxScale / currentScale
        }
        view1.transform = view1.transform.scaledBy(x: newScale, y: newScale)
        gesture.scale = 1
        
        //view1.transform = view1.transform.scaledBy(x: newScale, y: newScale)
        //view1.transform = view1.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        //gesture.scale = 1.0
        
        
    }
    
    var count = 0
    
    @objc func handleDoubleTap(){
        
        if count == 0 {
            
            myImage.addSubview(view1)
            
            view1.centerXAnchor.constraint(equalTo: myImage.centerXAnchor).isActive = true
            
            view1.centerYAnchor.constraint(equalTo: myImage.centerYAnchor).isActive = true
            
            view1.heightAnchor.constraint(equalToConstant: myImage.frame.height / 2).isActive = true
            
            view1.widthAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
            
            count = 1
            
        }
            
    else if count == 1 {
            
            view1.removeFromSuperview()
            count = 0
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        myActivityIndicator.isHidden=true
        myTextDisplay.isEnabled = false
        submitButton.isEnabled = false
        uploadButton.isEnabled = false
        
        
        let doubleTap = UITapGestureRecognizer(target: self, action:
            #selector(handleDoubleTap))
        
        doubleTap.numberOfTapsRequired = 2
        
        view.addGestureRecognizer(doubleTap)
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))

         view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinch)))
        
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }

    }
    
    
    @IBAction func selectPhoto(_ sender: Any) {
        var myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    
    // select photo and take photo use this
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        myImage.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        myImage.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
        
        //enable upload button
        uploadButton.isEnabled = true
    
    }
    
    @IBAction func uploadButtonTapped(_ sender: Any) {
        
        
        uploadImage(){ url in
            
            print("URL=         " + url!.absoluteString)
            
            if url == nil
        {
            self.uploadButton.isEnabled = true
            self.submitButton.isEnabled = false
            
            let alertController = UIAlertController(title: "Alert", message: "Oops! Something went wrong. Try again.", preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    else
        {
            
            self.submitButton.isEnabled = true
            
            if(self.uploadButton.isEnabled == false)
            {
                sleep(2)
                self.myActivityIndicator.isHidden=true
            }
            self.extractText(imageUrl: url!)
            }
            
        }
        
    }
    
    func uploadImage(completion: @escaping ((_ url:URL?) ->()))
    {
        takePhotoButton.isEnabled = false
        self.selectPhoto.isEnabled = false
        self.uploadButton.isEnabled = false
        myActivityIndicator.isHidden=false
        myActivityIndicator.startAnimating()
        
        let renderer = UIGraphicsImageRenderer(size: myImage.bounds.size)
        
        let image = renderer.image { ctx in
            
            myImage.drawHierarchy(in: myImage.bounds, afterScreenUpdates: true)
            
        }
        myImage.image = image
        let imageData = myImage.image?.jpegData(compressionQuality: 1)
        if(imageData == nil ) { return }
        
        let storageRef = Storage.storage().reference().child("test.jpg")
        let metaData = StorageMetadata()
        metaData.contentType="image/jpg"
        storageRef.putData(imageData!,metadata: metaData){
            (metadata,error) in
            if error == nil
            {
                print("success")
                storageRef.downloadURL(completion: {
                    (url,error) in completion(url!)
                })
            }
            
            else
            {
                print("error in upload")
                completion(nil)
                
            }
        }
    }
    
    func uploadImageTest()
    {
        takePhotoButton.isEnabled = false
        self.selectPhoto.isEnabled = false
        self.uploadButton.isEnabled = false
        
        let renderer = UIGraphicsImageRenderer(size: myImage.bounds.size)
        
        let image = renderer.image { ctx in
            
            myImage.drawHierarchy(in: myImage.bounds, afterScreenUpdates: true)
            
        }
        myImage.image = image
        let imageData = myImage.image?.jpegData(compressionQuality: 1)
        if(imageData == nil ) { return }
        
        
        let param = [
            "firstName"  : "Roshni",
            "status"     :"received"
        ]
        
        let uploadScriptUrl = URL(string:"http://localhost:8888/tireimages/upload.php")
        var request = URLRequest(url: uploadScriptUrl!)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary) as Data
        
        var configuration = URLSessionConfiguration.default
        
        
         myActivityIndicator.isHidden=false
         myActivityIndicator.startAnimating()
    
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if error != nil {
                print("error=\(String(describing: error))")
                
                let alertController = UIAlertController(title: "Alert", message: "Could not connect to server ", preferredStyle: UIAlertController.Style.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    print("OK")
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
                self.myActivityIndicator.isHidden = true
                self.uploadButton.isEnabled = false
                return
            }
            
            // You can print out response object
            print("******* response = \(String(describing: response))")
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            
            
            
                DispatchQueue.main.async {
                    
                    
                //image was not uploaded , enable upload button again
                    if((responseString?.isEqual(to: "uploads/"))!)
                    {
                        self.uploadButton.isEnabled = true
                        self.submitButton.isEnabled = false
                        
                        let alertController = UIAlertController(title: "Alert", message: "Oops! Something went wrong. Try again.", preferredStyle: UIAlertController.Style.alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                            (result : UIAlertAction) -> Void in
                            print("OK")
                        }
                        
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                    
                    }
                else
                    {   //successful upload , call extract
                        //self.extractText()
                        self.submitButton.isEnabled = true
                        
                        if(self.uploadButton.isEnabled == false)
                        {
                            sleep(2)
                            self.myActivityIndicator.isHidden=true
                        }
                    }
                

                }
                
 
        }
        task.resume()
     
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "test.jpg"
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
   
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        //extractText()
        let brand = myTextDisplay.text
        print(brand!)
        //let imageUrl = "parameters"
        let scriptUrl = "http://rmurali.pythonanywhere.com/feedback" + "?tirename=\(brand ?? "text")"
        
        let pythonUrl = URL(string: scriptUrl)
        var request = URLRequest(url: pythonUrl!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(String(describing: error))")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(String(describing: responseString))")
            
                
                DispatchQueue.main.async {
                   
                    let alertController = UIAlertController(title: "Success!", message: "Information has been submitted", preferredStyle: UIAlertController.Style.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        print("OK")
                    }
                    
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            
            
        }
        task.resume()
        //reset view controller
        sleep(2)
        takePhotoButton.isEnabled = true
        selectPhoto.isEnabled = true
        uploadButton.isEnabled = false
        submitButton.isEnabled = false
        myTextDisplay.text = ""
        myTextDisplay.isEnabled = false
        myImage.image = nil
        myImage.backgroundColor = UIColor.lightGray

    }
    
    func extractText(imageUrl: URL)
        {
        
        //let imageUrl = "http://localhost:8888/tireimages/uploads/test.jpg"
        let imageUrlText = imageUrl.absoluteString
        let scriptUrl = "http://rmurali.pythonanywhere.com/" + "?url=\(imageUrlText)"
        
        let pythonUrl = URL(string: scriptUrl)
        var request = URLRequest(url: pythonUrl!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(String(describing: error))")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(String(describing: responseString))")
            
            // Convert server json response to NSDictionary
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                
                print(json!)
                let firstNameValue = json!["hello"] as? String
                print(firstNameValue!)
                
                DispatchQueue.main.async {
                   self.myTextDisplay.isEnabled=true
                   self.myTextDisplay.text=firstNameValue
                    self.submitButton.isEnabled = true
                    
                    
                    let alertController = UIAlertController(title: "Check brand info", message: "Edit brand information if required", preferredStyle: UIAlertController.Style.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        print("OK")
                    }
                    
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    self.myTextDisplay.isHighlighted = true
                }
                
            }catch
            {
                print(error)
            }
            
        }
         task.resume()
        
    }
    
}

extension NSMutableData {
    
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

