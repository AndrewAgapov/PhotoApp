//
//  PhotosViewController.swift
//  PhotoApp
//
//  Created by Andrew on 2/12/16.
//  Copyright © 2016 AndrewAgapov. All rights reserved.
//

import UIKit



class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    let imagePicker = UIImagePickerController()
    let dateFormater = NSDateFormatter()
    var allImages = [UIImage]()
    var allLabels = [String]()
    let pathToDocumentsDirectory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        gettingPhotos()
        
    }
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let nav = self.navigationController?.navigationBar
        
        nav?.barStyle = UIBarStyle.BlackTranslucent
        nav?.tintColor = UIColor.whiteColor()
        nav?.backgroundColor = UIColor.blueColor()
    }
    
    
    
    func reloadPhotoView() {
        self.allImages = []
        self.allLabels = []
        gettingPhotos()
        self.photosCollectionView.reloadData()
        self.view.reloadInputViews()
        
    }
    
    
    // func to find some directory
    func contentsOfDirectoryAtPath(path: String) -> [String]? {
        guard let paths = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(path) else { return nil}
        return paths.map { aContent in (path as NSString).stringByAppendingPathComponent(aContent)}
    }
    
    
    
    // making array with photos from Documents directory
    func gettingPhotos() -> ([UIImage],[String]){
        let allContents = contentsOfDirectoryAtPath(pathToDocumentsDirectory)
        print(allContents)
        
        for file in allContents!{
            
            if (file.rangeOfString(".jpg") != nil){
                let myImage = UIImage(contentsOfFile: file)
                allImages.append(myImage!)
                let rangeOfName = Range(start: (file.rangeOfString("Documents/")?.endIndex)!, end: file.endIndex.advancedBy(-4))
                let ImageLabel = file.substringWithRange(rangeOfName)
                dateFormater.dateFormat = "EEEE d MMM yyyy"
                let label = NSDate(timeIntervalSince1970:
                    NSTimeInterval(ImageLabel)!)
                let dateLabel = dateFormater.stringFromDate(label)
                allLabels.append(dateLabel)
                print(dateLabel)
                print(ImageLabel)
            }
        }
        return (allImages, allLabels)
        
    }
    
    
    func makingImageName() -> String {
        let date = NSDate().timeIntervalSince1970  // using Unix Epoch Time
        let nameOfImage = String(date)
        return nameOfImage
    }
    

    
    
    
    
    
    // MARK: Working with camera and saving photo
    
    @IBAction func openCamera(sender: AnyObject) {
        
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera){
            
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .Camera
            imagePicker.cameraCaptureMode = .Photo
            presentViewController(imagePicker, animated: true, completion: nil)
            
        }
            
        else {
            let alert = UIAlertController(title: "Error", message: "App can't get acces to camera", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("Got an image")
        if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
            
            if let data = UIImageJPEGRepresentation(pickedImage, 0.1) {
                let filename = NSString(string: pathToDocumentsDirectory).stringByAppendingPathComponent("\(makingImageName()).jpg")
                
                data.writeToFile(filename, atomically: true)
                print("image saved with name \(filename)")
            }
        }
        
        imagePicker.dismissViewControllerAnimated(true, completion: {
            
            self.reloadPhotoView()
            
            
        })
    }
    
    
    
    
    
    
    
    
    
    //MARK: CollectionView DataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        return allImages.count
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell: PhotosCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! PhotosCollectionViewCell
        
        cell.photoImage.image = allImages[indexPath.row]

    
    // Dividing day and date to make day's font bold
        
        let rangeOfDay = Range(start: allLabels[indexPath.row].startIndex, end: (allLabels[indexPath.row].rangeOfString(" ")?.startIndex)!)
        let rangeOfDate = Range(start: (allLabels[indexPath.row].rangeOfString(" ")?.startIndex)!, end: allLabels[indexPath.row].endIndex)
        
        let dayLabel = allLabels[indexPath.row].substringWithRange(rangeOfDay).capitalizedString
        let dateLabel = allLabels[indexPath.row].substringWithRange(rangeOfDate)
        
        cell.dateLabel.textColor = UIColor.blackColor()
        cell.dateLabel.text = dateLabel
        cell.dayLabel.text = dayLabel
        
        return cell
    }
    
    
    
    
    @IBAction func refreshData(sender: AnyObject) {
       reloadPhotoView()
    }
    
}

