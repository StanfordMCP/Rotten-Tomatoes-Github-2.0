//
//  MoviesViewController.swift
//  rottenTomatoesClient
//
//  Created by Irene Onyeneho on 4/13/15.
//  Copyright (c) 2015 Irene Onyeneho. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var refreshControl: UIRefreshControl!
    
    var movies: [NSDictionary]! = [NSDictionary]()

    @IBOutlet weak var networkErrorView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
   // var movielist: [MoviesList] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.networkErrorView.hidden = true
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        //tableView.dataSource = self
     //   fetchMovies()

        
        var url = NSURL (string: "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=nxu96vjy2huu9g3vd3kjfd2g")
        //NSRUL's capture what you type in an address bar
        
        var request = NSURLRequest (URL: url!)
        //create a request, it's something that captures the url and captures what the caching settings are and data preferences for the request.
        
        SVProgressHUD.show()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if (error != nil) {
                self.networkErrorView.hidden = false
            }
            
            var json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
            
            self.movies = json["movies"] as [NSDictionary] //an array of dictionaries
            
            self.tableView.reloadData()
            
            SVProgressHUD.dismiss()
            
            //NSLog("got the response back: %@", movies)
            
            //Now you want to grab that data, it's in JSON right now, but you want to turn it into an array and a dictionary
            
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        

     
        

    }
    
    func tableView (tableView: UITableView, numberOfRowsInSection section: Int) ->Int {
        return movies.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as MovieCell
        
        var movie = movies [indexPath.row]
        
        cell.titleLabel.text = movie ["title"] as? String
        cell.synopsisLabel.text = movie ["synopsis"] as? String
        
        var url = movie.valueForKeyPath("posters.thumbnail") as? String
        
        cell.posterView.setImageWithURL(NSURL(string: url!)!)
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        NSLog ("navigating")
        
        //need to give the second view controller your current movie
        var movieDetailViewController = segue.destinationViewController as MovieDetailViewController
        
        var cell = sender as UITableViewCell
        var indexPath = tableView.indexPathForCell(cell)!
        
        movieDetailViewController.movie = movies[indexPath.row]
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
}
