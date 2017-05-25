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
    case couldNotCreateRoverImage(String)
    case noImageFound(String)
    case couldNotConvertDataToImage(String)
}

class RoverPostCardVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    //MARK: - Properties
    let networkingRequest:NASAClient = NASAClient(config: .default)
    let numOfImagesToShow: Int = 15
    var nasaData: [String:AnyObject]?
    var roverDetails: [RoverPhoto] = []
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
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
        
        //Sets look and feel of the header cell
        if indexPath.row == 0 {
            cell.nasaPhoto.image = UIImage(named: "Wallpaper1.jpg")
            cell.roverDetailLabel.isHidden = true
            cell.roverNameLabel.isHidden = true
            cell.actionButton.isHidden = true
            return cell
        }
        
        //Sets look at feel for other cells in the collection view
        cell.headerIcon.isHidden = true
        cell.headerInfoButton.isHidden = true
        cell.headerLabel.isHidden = true
        cell.homeButton.isHidden = true
        cell.roverDetailLabel.text = self.roverDetails[indexPath.row].date
        cell.roverNameLabel.text = self.roverDetails[indexPath.row].roverName
        cell.nasaPhoto.image = self.roverDetails[indexPath.row].thumbnailImage
        
        return cell
    }
    
    
    func setLayout(){
        self.navigationController?.isNavigationBarHidden = true
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let collectionViewWidth = collectionView!.contentSize.width
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: collectionViewWidth/2, height: 100)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        activityIndicator.center = self.view.center
        activityIndicator.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Wallpaper1"))
        activityIndicator.bringSubview(toFront: self.view)
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        
        self.collectionView!.collectionViewLayout = layout
        self.collectionView!.backgroundView = activityIndicator
    }
    
    func fetchData(){
        if(nasaData == nil){
            //If the data to be displayed is nil, show activity monitor so users know that the app is working to get it
            activityIndicator.startAnimating()
            
            //Make the network fetch request on the background thread
            DispatchQueue.global(qos: .background).async {
                self.networkingRequest.fetchData(url: MarsRover.Rovers(roverName: Rovers.Curiosity.rawValue).fullRequest) { (fetchSuccess, fetchedNasaImageData) in
                    if fetchSuccess {
                        //Update the properties and any UI componenets on main thread
                        DispatchQueue.main.async {
                            do{
                                self.nasaData = fetchedNasaImageData
                                try self.createRover(completion: { (roverImages) in
                                    self.roverDetails = roverImages
                                    self.collectionView?.dataSource = self
                                    self.activityIndicator.stopAnimating()
                                    self.collectionView?.reloadData()
                                })
                            }catch{
                                let message = DisplayErrorMessage(message: "Could not grab images succesfully", view: self)
                                message.showMessage()
                                
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
    
    //Displays an alert message that provides info on how to use the app
    @IBAction func infoButtonPressed(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "Welcome!", message: "This is the Nasa Rover Post Card Feature. This collects images from the rovers NASA currently has on Mars. Tap the icon in the bottom right of a image you like to add some text and send a postcard to a friend!", preferredStyle: .alert)
        let okay = UIAlertAction(title: "Got It", style: .default, handler: nil)
        alert.addAction(okay)
        self.present(alert, animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //Make the first row a headeer type row than spans the width of the screen
        if indexPath.row == 0
        {
            return CGSize(width: collectionView.contentSize.width, height: 250)
        }
        return CGSize(width: 384, height: 165);
    }
    
    func createRover(completion: ([RoverPhoto])->Void) throws {
        var count = 0
        let increaseByOne = 1
        let allPhotos:[[String:AnyObject]] = nasaData!["photos"] as! [[String:AnyObject]]
        var allRover: [RoverPhoto] = []
        var roverName: String
        var roverDate: String
        var roverImage: UIImage = UIImage()
        
        while  count <= numOfImagesToShow {
        //Randomly choose images out of all the fetched rover images
        let selectedPhoto: [String:AnyObject] = allPhotos[Int (arc4random_uniform(UInt32(allPhotos.count)))]
            
            guard let name = selectedPhoto["rover"]?["name"], let date = selectedPhoto["rover"]?["landing_date"] else {
                throw RoverImageGeneratorErrors.couldNotCreateRoverImage("Error grabbing data from dictionary")
            }
        
            do{
                roverName = name as! String
                roverDate = date as! String
                roverImage = try selectedPhoto.createImageFromJSONString(dataArray: selectedPhoto, key: "img_src")
            }catch {
                fatalError("Unable to create rover")
            }
            
        let rover  = RoverPhoto(name: roverName, date: roverDate, image: roverImage)
        allRover.append(rover)
        count += increaseByOne
            
        }
        completion(allRover)
    }
    
    //Segue to postcard view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MailSegue"{
            let sender = sender as! UIButton!
            let mailPostcardVC = segue.destination as! MailPostcardVC
            let selectedCell: NasaImageCell = sender!.superview?.superview as! NasaImageCell
            let selectedCellRoverImage: UIImage = selectedCell.nasaPhoto.image!
            mailPostcardVC.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Wallpaper1"))
            mailPostcardVC.postCardRoverImage.image = selectedCellRoverImage
        }
    }

}


