//
//  RoverPostCardViewCollectionViewController.swift
//  Proj12NASAapp
//
//  Created by Vernon G Martin on 5/16/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "NasaCell"

class RoverPostCardVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    //MARK: - Properties
    let networkingRequest:NasaApi = NasaApi(config: .default)
    var nasaData: [String:AnyObject] = [:]
    var roverDetails: [RoverPhoto] = []
    
    

    override func viewDidLoad() {
        self.collectionView?.dataSource = nil
        super.viewDidLoad()
        setLayout()
        networkingRequest.fetchData { (fetchSuccess, fetchedNasaImageData) in
            if fetchSuccess {
               self.nasaData = fetchedNasaImageData
                self.grabImageFromJson(completion: { (roverImages) in
                    self.roverDetails = roverImages
                    self.collectionView?.dataSource = self
                })
            } else {
                fatalError()
            }
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NasaImageCell
        
        cell.roverDetailLabel.text = self.roverDetails[indexPath.row].date
        cell.roverNameLabel.text = self.roverDetails[indexPath.row].roverName
        cell.nasaPhoto.image = self.roverDetails[indexPath.row].thumbnailImage
        
        return cell
    }
    
    func setLayout(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let collectionViewWidth = collectionView!.contentSize.width
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: collectionViewWidth/2, height: 100)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionView!.collectionViewLayout = layout
        self.collectionView!.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background"))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.row == 0
        {
            return CGSize(width: collectionView.contentSize.width, height: 100)
        }
        return CGSize(width: 160, height: 70);
    }
    
    func grabImageFromJson(completion: ([RoverPhoto])->Void){
        var count = 0
        let allPhotos:[[String:AnyObject]] = nasaData["photos"] as! [[String:AnyObject]]
        var allRover: [RoverPhoto] = []
        var roverName: String
        var roverDate: String
        var roverImage: UIImage = UIImage()
        
        while  count <= 9 {
        let selectedPhoto: [String:AnyObject] = allPhotos[Int (arc4random_uniform(UInt32(allPhotos.count)))]
        roverName = selectedPhoto["rover"]?["name"] as! String
        roverDate = selectedPhoto["rover"]?["landing_date"] as! String
        let imageString:String = selectedPhoto["img_src"] as! String
        guard let imageURL: URL = URL(string: imageString) else {
            print("Could not convert imagestring to URL")
            return
        }
        do {
            let imageData = try Data(contentsOf: imageURL)
            guard let image = UIImage(data: imageData) else {
                //FIXME: - Fix This return statement
                print("error no image found")
                return
            }
            roverImage = image
        } catch {
            print("error converting url to data and image")
        }
            
        let rover  = RoverPhoto(name: roverName, date: roverDate, image: roverImage)
        allRover.append(rover)
        count += 1
            
}
        completion(allRover)
    }

}


