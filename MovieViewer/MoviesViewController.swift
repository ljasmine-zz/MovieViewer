//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by jasmine_lee on 10/17/16.
//  Copyright © 2016 jasmine_lee. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var movieSearchResults: [NSDictionary]?
    var endpoint: String!
    var refreshControl: UIRefreshControl?
    var searchController: UISearchController?
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        filterMovies(searchText: searchText!)
        self.tableView.reloadData()
    }

    
    func filterMovies(searchText: String)
    {
        // Filter the array using the filter method
        if self.movies == nil {
            self.movieSearchResults = nil
            return
        }
        
        if (searchText.isEmpty) {
            self.movieSearchResults = self.movies
        } else {
            self.movieSearchResults = self.movies!.filter({( movie: NSDictionary) -> Bool in
                // to start, let's just search by name
                return (movie["title"] as! String).lowercased().range(of: searchText.lowercased()) != nil
            })
        }
        
        print(self.movieSearchResults?.count)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize a UIRefreshControl
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = UIColor(red: 1.0, green: 184.0/255.0, blue: 0, alpha: 1.0)
        refreshControl!.addTarget(self, action: #selector(MoviesViewController.refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl!, at: 0)
        tableView.dataSource = self
        tableView.delegate = self
        
//        networkErrorView.isHidden = false
        
        
        // replace navigation bar with search bar and search controller
        self.searchController = UISearchController(searchResultsController:  nil)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.delegate = self
        self.searchController?.searchBar.delegate = self
        
        self.searchController?.hidesNavigationBarDuringPresentation = false
        self.searchController?.dimsBackgroundDuringPresentation = true
        self.navigationItem.titleView = searchController?.searchBar
        
        self.definesPresentationContext = true
        
        networkRequest()
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        networkRequest()
    }
    
    func networkRequest() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        // why do we need to unwrap endpoint here
        let myURL = "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)"
        let url = URL(string: myURL)
        let request = NSURLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { (dataOrNil, response, error) in
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(
                    with: data, options:[]) as? NSDictionary {
                    print("response: \(responseDictionary)")
                    
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    self.tableView.reloadData()
                    
                    // Tell the refreshControl to stop spinning
                    self.refreshControl!.endRefreshing()
                }
            } else {
                // there is a network error
                //self.networkErrorView.isHidden = false
            }
        
            MBProgressHUD.hide(for: self.view, animated: true)
        })
        
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let movies = self.movieSearchResults {
            if movies.count > 0 {
                return movies.count
            }
        } else if let movies = self.movies {
            return movies.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        var displayedMovies : [NSDictionary] = []
        if (self.movieSearchResults != nil && self.movieSearchResults!.count > 0) {
            print("hi")
            displayedMovies = self.movieSearchResults!
        } else if self.movies != nil {
            displayedMovies = self.movies!
        }
        
        let movie = displayedMovies[indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        if let posterPath = movie["poster_path"] as? String
        {
            let baseURL = "https://image.tmdb.org/t/p/w500"
            let imageURL = URL(string: baseURL + posterPath)
            cell.posterImageView.setImageWith(imageURL!)
        }
        
        print("row \(indexPath.row)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        
        print("prepare for segue called")
    }

}
