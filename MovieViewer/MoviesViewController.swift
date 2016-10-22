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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: Public
    @IBOutlet weak var gridView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var movieSearchResults: [NSDictionary]?
    var endpoint: String!
    var refreshControl: UIRefreshControl?
    var refreshControl2: UIRefreshControl?
    var searchController: UISearchController?
    var selectedSegment: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // set data source and delegate
        tableView.dataSource = self
        tableView.delegate = self
        gridView.dataSource = self
        gridView.delegate = self

        // Initialize a UIRefreshControl
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = UIColor(red: 1.0, green: 184.0/255.0, blue: 0, alpha: 1.0)
        refreshControl!.addTarget(self, action: #selector(MoviesViewController.refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl!, at: 0)

        networkRequest()

        // replace navigation bar with search bar and search controller
        setUpSearchController()

        // decide which type of view to show, list or grid
        if selectedSegment == 0 {
            self.tableView.isHidden = false
            self.gridView.isHidden = true

            let gridViewButton = UIBarButtonItem(image: UIImage(named: "grid_view"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(switchViews))
            self.navigationItem.leftBarButtonItem = gridViewButton
        } else {
            self.tableView.isHidden = true
            self.gridView.isHidden = false

            let listViewButton = UIBarButtonItem(image: UIImage(named: "list_view"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(switchViews))
            self.navigationItem.leftBarButtonItem = listViewButton
        }

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (searchController!.isActive) && !(searchController!.searchBar.text?.isEmpty)! {
            return movieSearchResults!.count
        } else if let movies = self.movies {
            return movies.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.gridView.dequeueReusableCell(withReuseIdentifier: "PosterViewCell", for: indexPath) as! PosterViewCell

        let displayedMovies : [NSDictionary]
        if ((searchController?.isActive)! && !(searchController?.searchBar.text?.isEmpty)!) {
            displayedMovies = self.movieSearchResults!
        } else if self.movies != nil {
            displayedMovies = self.movies!
        } else {
            displayedMovies = []
        }

        let movie = displayedMovies[indexPath.row]

        if let posterPath = movie["poster_path"] as? String
        {
            let baseURL = "https://image.tmdb.org/t/p/w500"
            let imageURL = URL(string: baseURL + posterPath)
            let imageRequest = NSURLRequest(url: imageURL!)

            cell.posterImageView.setImageWith(
                imageRequest as URLRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in

                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterImageView.alpha = 0.0
                        cell.posterImageView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterImageView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterImageView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
        } else {
            let imageURL = URL(string: "https://cdn2.iconfinder.com/data/icons/picons-basic-1/57/basic1-044_file_document_error-512.png")
            cell.posterImageView.setImageWith(imageURL!)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = self.gridView.cellForItem(at: indexPath) as! PosterViewCell
        cell.posterImageView.alpha = 0.8
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = self.gridView.cellForItem(at: indexPath) as! PosterViewCell
        cell.posterImageView.alpha = 1.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (searchController!.isActive) && !(searchController!.searchBar.text?.isEmpty)! {
            return movieSearchResults!.count
        } else if let movies = self.movies {
            return movies.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let displayedMovies : [NSDictionary]
        if ((searchController?.isActive)! && !(searchController?.searchBar.text?.isEmpty)!) {
            displayedMovies = self.movieSearchResults!
        } else if self.movies != nil {
            displayedMovies = self.movies!
        } else {
            displayedMovies = []
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
            let imageRequest = NSURLRequest(url: imageURL!)

            cell.posterImageView.setImageWith(
                imageRequest as URLRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in

                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterImageView.alpha = 0.0
                        cell.posterImageView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterImageView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterImageView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
        } else {
            let imageURL = URL(string: "https://cdn2.iconfinder.com/data/icons/picons-basic-1/57/basic1-044_file_document_error-512.png")
            cell.posterImageView.setImageWith(imageURL!)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        filterMovies(searchText: searchText!)
    }
    

    // MARK: Private
    private dynamic func setUpSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.delegate = self
        self.searchController?.searchBar.delegate = self

        self.searchController?.hidesNavigationBarDuringPresentation = false
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.navigationItem.titleView = searchController?.searchBar
    }

    private dynamic func switchViews() {
        if selectedSegment == 0 {

            self.tableView.isHidden = true
            self.gridView.isHidden = false

            let listViewButton = UIBarButtonItem(image: UIImage(named: "list_view"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(switchViews))
            self.navigationItem.leftBarButtonItem = listViewButton

            selectedSegment = 1

        } else {

            self.tableView.isHidden = false
            self.gridView.isHidden = true

            let gridViewButton = UIBarButtonItem(image: UIImage(named: "grid_view"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(switchViews))
            self.navigationItem.leftBarButtonItem = gridViewButton

            selectedSegment = 0
        }
    }

    private dynamic func filterMovies(searchText: String)
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

        self.tableView.reloadData()
        self.gridView.reloadData()
    }

    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    private dynamic func refreshControlAction(refreshControl: UIRefreshControl) {
        networkRequest()
    }

    private dynamic func networkRequest() {
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
                    self.gridView.reloadData()

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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        let movie : NSDictionary
        var indexPath : IndexPath

        if selectedSegment == 0 {
            let cell = sender as! UITableViewCell
            indexPath = self.tableView.indexPath(for: cell)!
        } else {
            let cell = sender as! UICollectionViewCell
            indexPath = self.gridView.indexPath(for: cell)!
        }

        if ((searchController?.isActive)! && !(searchController?.searchBar.text?.isEmpty)!) {
            movie = movieSearchResults![indexPath.row]
        } else if self.movies != nil {
            movie = movies![indexPath.row]
        } else {
            movie = NSDictionary()
        }

        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie

        print("prepare for segue called")
    }


}
