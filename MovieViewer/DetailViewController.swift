//
//  DetailViewController.swift
//  MovieViewer
//
//  Created by jasmine_lee on 10/18/16.
//  Copyright © 2016 jasmine_lee. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var collapseButton: UIButton!
    
    var movie: NSDictionary!
    var isCollapse = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        infoView.alpha = 0
        infoView.frame.origin.y -= 50
        changeCollapseButton(name: "collapse")
    }
    
    func changeCollapseButton (name: String) {
        let origImage = UIImage(named: name)
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        collapseButton.setImage(tintedImage, for: .normal)
        collapseButton.tintColor = UIColor.white
    }
    
    @IBAction func didPressButton(_ sender: AnyObject) {
        if isCollapse {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.infoView.frame.origin.y += self.infoView.frame.height - 35
                self.view.layoutIfNeeded()
                self.changeCollapseButton(name: "expand")
                self.infoView.alpha = 0.6
                self.titleLabel.alpha = 0
                }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.infoView.frame.origin.y -= self.infoView.frame.height - 35
                self.view.layoutIfNeeded()
                self.changeCollapseButton(name: "collapse")
                self.infoView.alpha = 0.8
                self.titleLabel.alpha = 1
                }, completion: nil)
        }
        isCollapse = !isCollapse
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.infoView.frame.origin.y -= self.infoView.frame.height
            self.view.layoutIfNeeded()
            self.infoView.alpha = 0.75
            }, completion: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 1.0, green: 184.0/255.0, blue: 0, alpha: 1.0)

        let title = movie["title"] as? String
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let overview = movie["overview"] as? String
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        overviewLabel.frame.origin.y = titleLabel.frame.origin.y + titleLabel.frame.size.height + 5
        infoView.frame.size.height = titleLabel.frame.size.height + overviewLabel.frame.size.height + 35
        
        if let posterPath = movie["poster_path"] as? String {
            let baseURL = "https://image.tmdb.org/t/p/original"
            let imageURL = URL(string: baseURL + posterPath)
            posterImageView.setImageWith(imageURL!)
        }
        
        print(movie)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
