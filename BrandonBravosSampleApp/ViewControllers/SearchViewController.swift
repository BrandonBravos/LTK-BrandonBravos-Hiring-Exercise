//
//  SearchViewController.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/22/22.
//

import UIKit
import AlgoliaSearchClient

class SearchViewController: UIViewController {
    let headerView = HeaderSearchLabelView(withBackButton: true)
    private var searchResponse: [QueryResult] = []
    private var currentQuery = ""
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        headerView.searchView.searchTextField.becomeFirstResponder()
        
        AlgoliaSearchManager.shared.algoliaSearch(withString: "#LTK") { [weak self] result in
            DispatchQueue.main.async {
                self?.currentQuery = "LTK"
                var hitResponse = [QueryResult]()
                for hit in result.hits {
                    let json = hit.object as JSON
                    let test = QueryResult(withJson: json)
                    hitResponse.append(test)
                }
                self?.searchResponse = hitResponse
                self?.tableView.reloadData()
            }
        }
        
    }
    
    // remove the view
    @objc private func backButtonTapped(){
        self.modalTransitionStyle = .crossDissolve
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    
    // removes all duplicates from a search to display them in a collection view
    private func groupSearches() -> [QueryResult] {
        if searchResponse.count == 0 {
            return []
            
        }
        var dic: [String: QueryResult] = [:]
        for response in searchResponse {
            dic[response.filterHashtag(query: currentQuery).lowercased()] = response
        }
        var dictArray: [QueryResult] = []
        for (_, value) in dic {
            dictArray.append(value)
        }
        return sortQuerryArray(queries: dictArray)
    }
    
    // returns a query array with hashtags in front and profiles in back
    private func sortQuerryArray(queries: [QueryResult]) -> [QueryResult] {
        if queries.count < 1 {return []}
        var copy = queries
        var profiles: [QueryResult] = []
        let count = copy.count - 1
        for index in 0...count where copy[count - index].displayName != nil {
            profiles.append(copy.remove(at: count - index))
        }
        return copy + profiles
    }
    
}

// MARK: Delegates
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupSearches().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let query = groupSearches()[indexPath.row]
        cell.textLabel?.text = query.filterHashtag(query: currentQuery)
        cell.backgroundColor = query.displayName != nil ? .systemBlue : .white
        return cell
    }
}

extension SearchViewController: SearchDelegate {
    func searchEdited(searchTextField: UITextField, withText text: String) {
        guard text.count > 1 else {
            return }
        
        AlgoliaSearchManager.shared.algoliaSearch(withString: text) { [weak self] result in
            DispatchQueue.main.async {
                self?.currentQuery = text
                var hitResponse = [QueryResult]()
                for hit in result.hits {
                    let json = hit.object as JSON
                    let test = QueryResult(withJson: json)
                    hitResponse.append(test)
                }
                self?.searchResponse = hitResponse
                self?.tableView.reloadData()
            }
        }
    }
    
    
}

// MARK: Layout
extension SearchViewController {
    private func setUpView() {
        let headearBarHeight: CGFloat = 45
        headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchDown)
        headerView.backgroundColor = .white
        headerView.searchView.delegate = self
        headerView.searchView.layer.cornerRadius = headearBarHeight / 2
        headerView.isUserInteractionEnabled = true
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headearBarHeight)
        ])
        
        tableView.backgroundColor = .white
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: Custom Result
// this could be improved, right now there's two different types of indexes in my agolia, they should be combined to be just one.
// a singular profile-post combined index would be the solution
struct QueryResult: Codable {
    var id: String?
    var hashtags: [String] = []
    var displayName: String?
    
    init(withJson json: JSON) {
        self.id = json["id"]!.object() as? String
        if let hashtags = json["hashtags"]?.object() as? [String]{
            self.hashtags = hashtags
        } else { self.hashtags = [] }
        if json["displayName"] != nil {
            displayName = json["displayName"]?.object() as? String
        }
    }
    
    func filterHashtag(query:String) -> String {
        if displayName != nil {
            return displayName!
        }
        
        var closestMatch = hashtags.first ?? ""
        for hashtag in hashtags {
            if hashtag.contains(query.first!) {
                closestMatch = hashtag
            }
        }
        return closestMatch
    }
}
