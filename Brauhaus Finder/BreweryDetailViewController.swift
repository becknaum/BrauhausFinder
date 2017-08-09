//
//  BreweryDetailViewController.swift
//  Brauhaus Finder
//
//  Created by Rebekah Sippert on 8/8/17.
//
//

import UIKit

class BreweryDetailViewController : UIViewController {
    
    var brewery: Brewery?
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var websiteButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        nameLabel.text = brewery?.name
        descriptionLabel.text = brewery?.description
        setUpImage()
    }
    
    func setUpImage() {
        guard let url = brewery?.imageUrl else {
            return
        }
        
        BreweryDB.fetchBreweryImageData(imageUrl: url) {
            imageData, error in
            
            guard let imageData = imageData, error == nil else {
                print("Could not fetch image")
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: imageData)
            }
        }
    }
    
    @IBAction func visitWebsite() {
        if let website = brewery?.websiteUrl {
            UIApplication.shared.open(website)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
