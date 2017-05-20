//
//  RoverPostCardViewCollectionViewController.swift
//  Proj12NASAapp
//
//  Created by Vernon G Martin on 5/16/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "NasaCell"

enum RoverImageGeneratorErrors: Error{
    case couldNotConvertString(String)
    case noImageFound(String)
    case couldNotConvertDataToImage(String)
}

class RoverPostCardVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    //MARK: - Properties
    let networkingRequest:NASAClient = NASAClient(config: .default)
    let numOfImagesToShow: Int = 16
    var nasaData: [String:AnyObject]?
    var roverDetails: [RoverPhoto] = []
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //While fetching data show activity monitor so user knows something is loading
        if(nasaData == nil){
            activityIndicator.startAnimating()
            
            //Make the network fetch request on the background thread
            DispatchQueue.global(qos: .background).async {
                self.networkingRequest.fetchData { (fetchSuccess, fetchedNasaImageData) in
                    if fetchSuccess {
                        //Update the properties and any UI componenets on main thread
                        DispatchQueue.main.async {
                            do{
                            self.nasaData = fetchedNasaImageData
                            try self.grabImageFromJson(completion: { (roverImages) in
                            self.roverDetails = roverImages
                            self.collectionView?.dataSource = self
                            self.activityIndicator.stopAnimating()
                            self.collectionView?.reloadData()
                            })
                            }catch{
                                
                            }
                }
            } else {
                //If images cannot be retrieved crash the program - nothing else can be done without them
                fatalError()
                    }
                }
            }
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        //If there is no data fetched from the API set the num of sections to 0 else set it to 1
        return (nasaData == nil) ? 0 : 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numOfImagesToShow
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NasaImageCell
        
        if indexPath.row == 0 {
            cell.nasaPhoto.image = UIImage(named: "HeaderImage.jpg")
            cell.roverDetailLabel.isHidden = true
            cell.roverNameLabel.isHidden = true
            cell.actionButton.isHidden = true
            return cell
        }
        
        cell.headerIcon.isHidden = true
        cell.headerInfoButton.isHidden = true
        cell.headerLabel.isHidden = true
        cell.roverDetailLabel.text = self.roverDetails[indexPath.row].date
        cell.roverNameLabel.text = self.roverDetails[indexPath.row].roverName
        cell.nasaPhoto.image = self.roverDetails[indexPath.row].thumbnailImage
        
        return cell
    }
    
    
    func setLayout(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let collectionViewWidth = collectionView!.contentSize.width
        let label = UILabel()
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: collectionViewWidth/2, height: 100)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        //label.text = "Loading your images"
        
        activityIndicator.center = self.view.center
        activityIndicator.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        activityIndicator.addSubview(label)
        activityIndicator.bringSubview(toFront: self.view)
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        
       // label.textAlignment = NSTextAlignment.center
      //  label.frame = CGRect(x: 40 + 5,
//                             y: 0,
//                             width: 50 - 40 - 15,
//                             height: 20)
        
        
        self.collectionView!.collectionViewLayout = layout
        self.collectionView!.backgroundView = activityIndicator
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "Welcome", message: "This is the Nasa Rover Galleries App. This app collects images from the rovers NASA currently has on Mars. Tap the icon in the bottom right of a image you like to add some text and send a postcard to a fried!", preferredStyle: .alert)
        let okay = UIAlertAction(title: "Got It", style: .default, handler: nil)
        alert.addAction(okay)
        self.present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //Make the first row a headeer type row than spans the width of the screen
        if indexPath.row == 0
        {
            return CGSize(width: collectionView.contentSize.width, height: 250)
        }
        return CGSize(width: 256, height: 165);
    }
    
    // Mark: Error reporting
    func reportError(message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func grabImageFromJson(completion: ([RoverPhoto])->Void) throws {
        var count = 0
        let allPhotos:[[String:AnyObject]] = nasaData!["photos"] as! [[String:AnyObject]]
        var allRover: [RoverPhoto] = []
        var roverName: String
        var roverDate: String
        var roverImage: UIImage = UIImage()
        
        while  count <= numOfImagesToShow {
        //Randomly choose images out of all the fetched rover images
        let selectedPhoto: [String:AnyObject] = allPhotos[Int (arc4random_uniform(UInt32(allPhotos.count)))]
        roverName = selectedPhoto["rover"]?["name"] as! String
        roverDate = selectedPhoto["rover"]?["landing_date"] as! String
        let imageString:String = selectedPhoto["img_src"] as! String
        guard let imageURL: URL = URL(string: imageString) else {
            throw RoverImageGeneratorErrors.couldNotConvertString("Could not create image URL String")
        }
        do {
            let imageData = try Data(contentsOf: imageURL)
            guard let image = UIImage(data: imageData) else {
                throw RoverImageGeneratorErrors.couldNotConvertDataToImage("Could not convert to image")
            }
            roverImage = image
        } catch {
            reportError(message: "Error converting or getting images from space")
        }
            
        let rover  = RoverPhoto(name: roverName, date: roverDate, image: roverImage)
        allRover.append(rover)
        count += 1
            
        }
        completion(allRover)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MailSegue"{
            let sender = sender as! UIButton!
            let mailPostcardVC = segue.destination as! MailPostcardVC
            let selectedCell: NasaImageCell = sender!.superview?.superview as! NasaImageCell
            let selectedCellRoverImage: UIImage = selectedCell.nasaPhoto.image!
            mailPostcardVC.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
            mailPostcardVC.postCardRoverImage.image = selectedCellRoverImage
        }
    }

}


