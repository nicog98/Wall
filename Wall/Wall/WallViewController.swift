//
//  WallViewController.swift
//  Wall
//
//  Represents a Wall in a collection view.
//
//      APIs used:
//        UICollectionView 2 - Main "wall" interface, includes multiple custom cells
//        UIToolBar 2 - To display bar button items that segue to content view controllers, integral part of the UI
//        UIImagePickerController (FOR IPAD) 1 - Points for UI, developed with iPad implementation in mind, this brings up camera and photo library separately for selecting images
//        UIPopoverPresentationController 2 - Used in this view controller for bringing up photo library (2 points for use in entire program)
//        PHPhotoLibrary 1 - Used for storing photos taken on camera in iPad in photo library (used again in ContentViewControllers->CameraViewController
//        MLMediaPickerController 2 - Used for choosing songs from music library (downloaded songs only), 2 points for selecting, playing, pausing
//        UIDocumentPicker 1 - Used for picking documents from user's device and embedding them in a wall
//        AVPlayer 1 - Plays videos selected from photo library
//        CMPedometer 1 - Counts number of steps taken since the creation of this wall
//        CLLocationManager 2 - Gets users current location upon opening and interacting with this wall, used again for adding annotations for coupled MapView
//
//  Created by Nicolai Garcia on 11/27/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import MapKit
import MobileCoreServices
import Photos
import CoreMotion

protocol WallViewControllerDelegate {
    func saveWall(wall: Wall, at index: Int)
}

class WallViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate,
MPMediaPickerControllerDelegate, UIDocumentPickerDelegate, UIPopoverPresentationControllerDelegate,
CameraViewControllerDelegate, DrawViewControllerDelegate, JournalViewControllerDelegate, SliderViewControllerDelegate {
    
    var wall: Wall?
    
    var delegate: WallViewControllerDelegate?
    
    @IBOutlet weak var wallCollectionView: UICollectionView! {
        didSet {
            wallCollectionView.dataSource = self
            wallCollectionView.delegate = self
        }
    }
    
    @IBOutlet weak var contentBar: UIToolbar!
    
    @IBOutlet weak var deleteBar: UIToolbar!
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    // MARK: ADD FROM LIBRARY ON IPAD
    
    var imagePicker: UIImagePickerController?
    
    override func viewWillAppear(_ animated: Bool) {
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            if contentBar.items?.count == 9 {
                var items = [UIBarButtonItem]()
                items.append(
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                )
                items.append(
                    UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFromLibrary(_:)))
                )
                contentBar.items = contentBar.items! + items
            }
        }
    }
    
    @objc func addFromLibrary(_ sender: UIBarButtonItem) {
        imagePicker = UIImagePickerController()
        imagePicker?.modalPresentationStyle = UIModalPresentationStyle.popover
        imagePicker?.sourceType = .photoLibrary
        imagePicker?.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker?.delegate = self
        let popoverController = imagePicker?.popoverPresentationController
        popoverController!.permittedArrowDirections = UIPopoverArrowDirection.any
        popoverController!.barButtonItem = sender
        present(imagePicker!, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addAsset(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (success, error) in
            if !success {
                print("Error adding image to photo library")
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var aspectRatio: CGFloat?
        if let chosenImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
            aspectRatio = chosenImage.size.height / chosenImage.size.width
            if (picker.sourceType == .camera) {
                addAsset(image: chosenImage)
                capturedPhoto(UIImageJPEGRepresentation(chosenImage, 1.0)!, aspectRatio!)
                imagePicker?.presentingViewController?.dismiss(animated: true)
            }
        }
        if let chosenImageURL = info[UIImagePickerControllerImageURL] as? URL {
            choseImage(chosenImageURL, aspectRatio!)
            imagePicker?.presentingViewController?.dismiss(animated: true)
        } else if let chosenMovieURL = info[UIImagePickerControllerMediaURL] as? URL {
            choseMovie(chosenMovieURL)
            imagePicker?.presentingViewController?.dismiss(animated: true)
        }
    }
    
    // MARK: Add to data source
    
    func addItem(type: Post.postType, url: URL?, data: Data?, aspectRatio: Float?, location: CLLocation?) {
        var newPost = Post(type)
        newPost.url = url ?? nil
        newPost.data = data ?? nil
        newPost.aspectRatio = aspectRatio ?? nil
        newPost.latitude = location?.coordinate.latitude
        newPost.longitude = location?.coordinate.longitude
        wall?.posts.append(newPost)
        delegate?.saveWall(wall: wall!, at: wall!.wallIndex!)
        wallCollectionView.reloadData()
    }
    
    func choseImage(_ imageURL: URL, _ aspectRatio: CGFloat) {
        addItem(type: .image,
                url: imageURL,
                data: nil,
                aspectRatio: Float(aspectRatio),
                location: location
        )
    }
    
    func choseMovie(_ movieURL: URL) {
        addItem(type: .movie,
                url: movieURL,
                data: nil,
                aspectRatio: nil,
                location: location
        )
    }
    
    func capturedPhoto(_ imageData: Data, _ aspectRatio: CGFloat) {
        addItem(type: .image,
                url: nil,
                data: imageData,
                aspectRatio: Float(aspectRatio),
                location: location
        )
    }
    
    func saveDrawing(drawingImageData: Data, aspectRatio: CGFloat, existingIndex: Int?) {
        var newPost = Post(.drawing)
        if existingIndex != nil {
            newPost = (wall?.posts[existingIndex!])!
        }
        newPost.data = drawingImageData
        newPost.aspectRatio = Float(aspectRatio)
        if existingIndex != nil {
            wall?.posts.remove(at: existingIndex!)
            wall?.posts.insert(newPost, at: existingIndex!)
        } else {
            newPost.latitude = location?.coordinate.latitude
            newPost.longitude = location?.coordinate.longitude
            wall?.posts.append(newPost)
        }
        delegate?.saveWall(wall: wall!, at: wall!.wallIndex!)
        wallCollectionView.reloadData()
    }
    
    func addMusic(musicURL: URL, artworkData: Data?, aspectRatio: CGFloat?) {
        var newPost = Post(.song)
        newPost.url = musicURL
        newPost.latitude = location?.coordinate.latitude
        newPost.longitude = location?.coordinate.longitude
        if artworkData != nil, aspectRatio != nil {
            newPost.data = artworkData
            newPost.aspectRatio = Float(aspectRatio!)
        }
        wall?.posts.append(newPost)
        delegate?.saveWall(wall: wall!, at: wall!.wallIndex!)
    }
    
    private func getTimeAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func savedText(text: String, existingIndex: Int?) {
        var newPost = Post(.text)
        if existingIndex != nil {
            newPost = (wall?.posts[existingIndex!])!
        }
        newPost.textContent = text
        newPost.latitude = location?.coordinate.latitude
        newPost.longitude = location?.coordinate.longitude
        if existingIndex != nil {
            wall?.posts.remove(at: existingIndex!)
            wall?.posts.insert(newPost, at: existingIndex!)
        } else {
            newPost.name = getTimeAsString()
            newPost.latitude = location?.coordinate.latitude
            newPost.longitude = location?.coordinate.longitude
            wall?.posts.append(newPost)
        }
        delegate?.saveWall(wall: wall!, at: wall!.wallIndex!)
        wallCollectionView.reloadData()
    }
    
    func addFile(fileURL: URL) {
        addItem(type: .file,
                url: fileURL,
                data: nil,
                aspectRatio: nil,
                location: location)
    }
    
    // MARK: Content Segues
    
    @IBAction func draw(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "drawPage", sender: self)
    }
    
    @IBAction func camera(_ sender: UIBarButtonItem) {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker = UIImagePickerController()
                imagePicker!.sourceType = .camera
                imagePicker!.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
                present(picker, animated: true, completion: nil)
            }
        } else {
            performSegue(withIdentifier: "cameraPage", sender: self)
        }
    }
    
    @IBAction func journal(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "journalPage", sender: self)
    }
    
    // MARK: UIDocumentPickerController
    
    var documentp = UIDocumentPickerViewController(documentTypes: WallViewController.constants.types, in: .import)
    
    @IBAction func importFile(_ sender: UIBarButtonItem) {
        documentp.delegate = self
        present(documentp, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            addFile(fileURL: url)
        }
    }
    
    // MARK: MPMediaPickerController
    
    var picker = MPMediaPickerController()
    
    @IBAction func music(_ sender: UIBarButtonItem) {
        present(picker, animated: true)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        if let mediaItem = mediaItemCollection.items.first, !mediaItem.isCloudItem {
            var aspectRatio: CGFloat?
            var imageData: Data?
            if let artworkImage = mediaItem.artwork?.image(at: CGSize(width: (mediaItem.artwork?.bounds.width)!, height: (mediaItem.artwork?.bounds.height)!)) {
                aspectRatio = artworkImage.size.width/artworkImage.size.height
                imageData = UIImageJPEGRepresentation(artworkImage, 1.0)
            }
            let songURL = mediaItem.assetURL
            addMusic(musicURL: songURL!, artworkData: imageData, aspectRatio: aspectRatio)
            dismiss(animated: true, completion: nil)
            wallCollectionView.reloadData()
        }
    }
    
    // MARK: Cell Size
    
    @IBAction func slider(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "sliderPopover", sender: sender)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    var lastWidthDivider: Float?
    
    var newCellWidthDivider: Float = WallViewController.constants.widthDivider
    
    func sliderViewController(changedSizeTo widthDivider: Float) {
        lastWidthDivider = widthDivider
        newCellWidthDivider = WallViewController.constants.widthDivider + (WallViewController.constants.widthDivider * (-1 * widthDivider))
        wallCollectionView.reloadData()
    }
    
    // MARK: Collection View Data Source Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wall?.posts.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = wall?.posts[indexPath.item]
        if post?.type == .image {
            let cell = wallCollectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
            if let imageCell = cell as? ImageWallCollectionViewCell {
                if let url = wall?.posts[indexPath.item].url {
                    imageCell.fetchImage(url)
                    imageCell.sizeToFit()
                } else if let data = wall?.posts[indexPath.item].data {
                    imageCell.imageView.image = UIImage(data: data)
                    imageCell.sizeToFit()
                }
            }
            cell.layer.cornerRadius = WallViewController.constants.cornerRadius
            return cell
        } else if post?.type == .movie {
            let cell = wallCollectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath)
            if let movieCell = cell as? MovieWallCollectionViewCell {
                movieCell.movieURL = wall?.posts[indexPath.item].url
            }
            cell.layer.cornerRadius = WallViewController.constants.cornerRadius
            return cell
        } else if post?.type == .drawing {
            let cell = wallCollectionView.dequeueReusableCell(withReuseIdentifier: "drawingCell", for: indexPath)
            if let drawingCell = cell as? DrawingWallCollectionViewCell {
                if let data = wall?.posts[indexPath.item].data {
                    drawingCell.imageView.image = UIImage(data: data)
                    drawingCell.sizeToFit()
                }
            }
            cell.layer.cornerRadius = WallViewController.constants.cornerRadius
            return cell
        } else if post?.type == .song {
            let cell = wallCollectionView.dequeueReusableCell(withReuseIdentifier: "songCell", for: indexPath)
            if let songCell = cell as? MusicWallCollectionViewCell {
                if let url = wall?.posts[indexPath.item].url {
                    songCell.fetchSong(songURL: url)
                }
                if let imageData = wall?.posts[indexPath.item].data {
                    songCell.imageView.image = UIImage(data: imageData)
                }
                songCell.sizeToFit()
            }
            cell.layer.cornerRadius = WallViewController.constants.cornerRadius
            return cell
        } else if post?.type == .text {
            let cell = wallCollectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath)
            if let textCell = cell as? JournalWallCollectionViewCell {
                textCell.title.layer.cornerRadius = WallViewController.constants.cornerRadius
                textCell.title.text = wall?.posts[indexPath.item].name
            }
            cell.layer.cornerRadius = WallViewController.constants.cornerRadius
            return cell
        } else if post?.type == .file {
            let cell = wallCollectionView.dequeueReusableCell(withReuseIdentifier: "importCell", for: indexPath)
            if let fileCell = cell as? ImportWallCollectionViewCell {
                fileCell.textField.text = post?.url?.lastPathComponent
            }
            cell.layer.cornerRadius = WallViewController.constants.cornerRadius
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if deleteBar.isHidden == false, contentBar.isHidden == true {
            deleteBar.isHidden = true
            contentBar.isHidden = false
        } else {
            if wall?.posts[indexPath.item].type == .movie {
                performSegue(withIdentifier: "playMovie", sender: self)
            } else if wall?.posts[indexPath.item].type == .image {
                performSegue(withIdentifier: "showImage", sender: self)
            } else if wall?.posts[indexPath.item].type == .drawing {
                performSegue(withIdentifier: "drawPage", sender: self)
            } else if wall?.posts[indexPath.item].type == .song {
                if let songCell = wallCollectionView.cellForItem(at: indexPath) as? MusicWallCollectionViewCell {
                    songCell.play()
                }
            } else if wall?.posts[indexPath.item].type == .text {
                performSegue(withIdentifier: "journalPage", sender: self)
            } else if wall?.posts[indexPath.item].type == .file {
                //documentp = UIDocumentPickerViewController(url: (wall?.posts[indexPath.item].url)!, in: .exportToService)
                documentp = UIDocumentPickerViewController(documentTypes: WallViewController.constants.types, in: .open)
                present(documentp, animated: true, completion: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let aspectRatio = wall?.posts[indexPath.item].aspectRatio {
            let width = self.view.frame.width / CGFloat(newCellWidthDivider)
            let height = CGFloat(aspectRatio) * width
            return CGSize(width: width, height: height)
        } else if wall?.posts[indexPath.item].type == .text {
            let width = self.view.frame.width / CGFloat(newCellWidthDivider)
            let height = width
            return CGSize(width: width, height: height)
        }
        return CGSize(width: WallViewController.constants.placeholderDimension, height: WallViewController.constants.placeholderDimension)
    }
    
    // MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = wall?.name
        picker.delegate = self
        deleteBar.isHidden = true
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchOut(_:)))
        self.view.addGestureRecognizer(pinch)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureHandler(_:)))
        self.view.addGestureRecognizer(longPress)
        startPedometerUpdates()
        wallCollectionView.reloadData()
        locationManager.requestWhenInUseAuthorization()
        startAndSaveUpdates()
    }
    
    @objc func pinchOut(_ sender: UIPinchGestureRecognizer) {
        performSegue(withIdentifier: "showMap", sender: self)
    }
    
    // MARK: Delete Items
    
    var deleteIndexPath: IndexPath?
    
    @objc func longPressGestureHandler(_ sender: UILongPressGestureRecognizer) {
        let p = sender.location(in: wallCollectionView)
        
        if let selectedIndexPath = wallCollectionView.indexPathForItem(at: p) {
            deleteIndexPath = selectedIndexPath
            contentBar.isHidden = true
            deleteBar.isHidden = false
        }
    }
    
    @IBAction func deleteItem(_ sender: UIBarButtonItem) {
        if let _ = deleteIndexPath {
            if wall?.posts[deleteIndexPath!.item].type == .song {
                if let songCell = wallCollectionView.cellForItem(at: deleteIndexPath!) as? MusicWallCollectionViewCell {
                    if songCell.player.isPlaying {
                        songCell.player.pause()
                    }
                }
            }
            wall?.posts.remove(at: deleteIndexPath!.item)
            deleteBar.isHidden = true
            contentBar.isHidden = false
            delegate?.saveWall(wall: wall!, at: (wall?.wallIndex)!)
            wallCollectionView.reloadData()
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cameraVC = segue.destination as? CameraViewController {
            cameraVC.delegate = self
        } else if let avc = segue.destination as? AVPlayerViewController {
            if let movieURL = wall?.posts[(wallCollectionView.indexPathsForSelectedItems?.first?.item)!].url {
                let player = AVPlayer(url: movieURL)
                avc.player = player
                player.play()
            }
        } else if let imageVC = segue.destination as? ImageViewController {
            if let imageCell = wallCollectionView.cellForItem(at: (wallCollectionView.indexPathsForSelectedItems?.first)!) as? ImageWallCollectionViewCell {
                imageVC.image = imageCell.imageView.image
            }
        } else if let drawingVC = segue.destination as? DrawViewController {
            drawingVC.delegate = self
            for selectedCellIndexPath in wallCollectionView.indexPathsForSelectedItems! {
                // song cell could be selected to play music while opening drawing
                if let _ = wallCollectionView.cellForItem(at: selectedCellIndexPath) as? DrawingWallCollectionViewCell {
                    if let drawingData = wall?.posts[(wallCollectionView.indexPathsForSelectedItems?.first?.item)!].data {
                        drawingVC.existingDrawing = UIImage(data: drawingData)
                        drawingVC.indexOfExistingDrawing = wallCollectionView.indexPathsForSelectedItems?.first?.item
                    }
                }
            }
        } else if let journalVC = segue.destination as? JournalViewController {
            journalVC.delegate = self
            for selectedCellIndexPath in wallCollectionView.indexPathsForSelectedItems! {
                if let _ = wallCollectionView.cellForItem(at: selectedCellIndexPath) as? JournalWallCollectionViewCell {
                    if let text = wall?.posts[(wallCollectionView.indexPathsForSelectedItems?.first?.item)!].textContent {
                        journalVC.text = text
                        journalVC.indexOfExistingText = wallCollectionView.indexPathsForSelectedItems?.first?.item
                    }
                }
            }
        } else if let mapVC = segue.destination as? MapViewController {
            mapVC.posts = wall?.posts
        } else if let sliderViewController = segue.destination as? SliderViewController {
            sliderViewController.modalPresentationStyle = .popover
            sliderViewController.popoverPresentationController?.delegate = self
            sliderViewController.delegate = self
            sliderViewController.lastValue = lastWidthDivider ?? 0.0
        }
    }
    
    // MARK: Location
    
    let locationManager = CLLocationManager()
    
    var location: CLLocation?
    var date: Date?
    
    func startAndSaveUpdates() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = WallViewController.constants.distanceFilter
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        date = location?.timestamp
    }
    
    // MARK: Pedometer
    
    
    @IBOutlet weak var steps: UIBarButtonItem!
    
    var pedometer = CMPedometer()
    
    func startPedometerUpdates() {
        if CMPedometer.isStepCountingAvailable() {
            if let startDate = wall?.dateCreated {
                pedometer.startUpdates(from: startDate, withHandler: { (pedometerData, error) in
                    if let pedData = pedometerData {
                        self.steps.title = "STEPS: \(pedData.numberOfSteps)"
                    }
                })
            }
        }
    }
    
}

extension WallViewController {
    private struct constants {
        static let widthDivider: Float = 2.25
        static let placeholderDimension: Int = 200
        static let distanceFilter: CLLocationDistance = 250
        static let types: [String] = [String(kUTTypeImage),
                                      String(kUTTypePDF),
                                      String(kUTTypeURL),
                                      String(kUTTypeMP3),
                                      String(kUTTypeData),
                                      String(kUTTypeHTML)]
        static let cornerRadius: CGFloat = 8.0
    }
}
