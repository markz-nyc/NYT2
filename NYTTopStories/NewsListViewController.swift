//
//  NewsListViewController.swift
//  NYTTopStories
//
//  Created by Mark Zhong on 9/12/17.
//  Copyright © 2017 Mark Zhong. All rights reserved.
//

import UIKit
import Kingfisher
import DGElasticPullToRefresh
import NVActivityIndicatorView

class NewsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    let apikey = "6e65e494834645fda986fe53937a998f"
    var sector = "home"
    var newsArr:[NewsModel]? = []
    let waitingView = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.size.width*0.5-20,y: UIScreen.main.bounds.size.height*0.5-40, width: 40, height: 40), type:.lineSpinFadeLoader, color:UIColor.purple)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchNYTJson(fromSource: sector)
        pullRefreshEffectct()

        // Show MenuViewController
        if self.revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            self.revealViewController().rearViewRevealWidth = 250
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())

            let nav = self.revealViewController().rearViewController as! UINavigationController
            let menuVC = nav.topViewController as! MenuViewController
            menuVC.chooseDelegate = self
        }

    }
 
    fileprivate func pullRefreshEffectct() {
                let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        newsTableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            // Do not forget to call dg_stopLoading() at the end
            self?.fetchNYTJson(fromSource: self?.sector ?? "home")
            self?.newsTableView.reloadData()
            self?.newsTableView.dg_stopLoading()
            }, loadingView: loadingView)
        newsTableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        newsTableView.dg_setPullToRefreshBackgroundColor(newsTableView.backgroundColor!)
    }
    
    // MARK: - Parse NYT API Json

    func fetchNYTJson(fromSource provider:String) {
        waitingView.startAnimating()
        self.view.addSubview(waitingView)
        sector = provider
        let nytEndpoint = "http://api.nytimes.com/svc/topstories/v2/\(sector).json?api-key=\(apikey)"
        
        guard let url = URL(string: nytEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url){ (data,response,error) in
            
            if error != nil {
                print(error!)
                return
            }
            do {
                if let data = data {
                    let json = try JSONSerialization.jsonObject(with: data, options:[]) as! [String: Any]
     
                    if let articlesFromJson = json["results"] as? [[String:Any]]{
                        //print(articlesFromJson)
                        
                        for articlesFromJson in articlesFromJson {
                            let article = NewsModel()

                            if let title = articlesFromJson["title"] as? String, let section = articlesFromJson["section"] as? String, let abstract = articlesFromJson["abstract"] as? String, let url = articlesFromJson["url"] as? String {

                                article.title = title
                                article.section = section
                                article.abstract = abstract
                                article.url = url

                            }
                            //Find normal size image url from nested Json
                            if let mutimedia = articlesFromJson["multimedia"] as? [[String:Any]]{
                                
                                for obj in mutimedia {
                                    if let format = obj["format"] as? String{
                                        if format.range(of:"mediumThreeByTwo210") != nil {
                                            if let url = obj["url"] as? String{
                                                article.imageUrl = url
                                            }
                                        }
                                    }
                                }
                            }
                            self.newsArr?.append(article)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.waitingView.stopAnimating()
                    self.newsTableView.reloadData()
                }
                        
            }catch let error as NSError{
                print(error)
                return
            }
        }
        task.resume()
        
    }
    
    // MARK: - Table view delegate and methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = newsTableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! NewsCell
        cell.newsTitle.text = self.newsArr?[indexPath.item].title
        cell.newsSection.text = self.newsArr?[indexPath.item].section
    
        if self.newsArr?[indexPath.item].imageUrl != nil{
            //Use Kingfisher to cache web image
            let url = URL(string: (self.newsArr?[indexPath.item].imageUrl)!)
            cell.newsImage.kf.setImage(with: url, placeholder: UIImage(named:"defaultPhoto.png"))

        }else{
            cell.newsImage.image = UIImage(named:"defaultPhoto.png")
            print("missing image url index is:", indexPath.row)
        }
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let webVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "web") as! WebViewController
        webVC.url = self.newsArr?[indexPath.item].url
        self.navigationController!.pushViewController(webVC, animated: true)
        self.newsTableView.deselectRow(at: indexPath, animated: true)

    }
}

extension NewsListViewController: MenuSectorDelegate{
    func reloadTableView(sector: String) {
        fetchNYTJson(fromSource: sector)
        self.newsArr?.removeAll()
        self.newsTableView.reloadData()
    }
}

