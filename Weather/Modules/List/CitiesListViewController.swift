//
//  CitiesListViewController.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 29.11.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import UIKit
import SDWebImage

protocol CitiesScreenEventsHandlerProtocol: ScreenEventsHandlerProtocol {
    func onScreenReady()
    func onSearch(text: String)
    func onAdd(city: City)
    func onDelete(cityIdx: Int)
    func onUpdate()
}

class CitiesListViewController: UIViewController, SearchTableDataSourceDelegate {
    
    var eventsHandler: CitiesScreenEventsHandlerProtocol?
    
    lazy var tableView = UITableView()
    
    var cities: [City] = []
    
    lazy var tableViewController: UITableViewController = {
        let tvc = UITableViewController()
        tvc.tableView.delegate = searchesDataSource
        tvc.tableView.dataSource = searchesDataSource
        
        tvc.tableView.register(UINib(nibName: CityWeatherCell.theClassName, bundle: nil), forCellReuseIdentifier: CityWeatherCell.identifier)
        tvc.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        tvc.tableView.rowHeight = CityWeatherCell.height
        
        if #available(iOS 11.0, *) {
            tvc.tableView.insetsContentViewsToSafeArea = true;
            tvc.tableView.contentInsetAdjustmentBehavior = .never;
        }
        
        return tvc
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        
        let r = UIRefreshControl()
        r.tintColor = .lightGray
        r.addTarget(self, action: #selector(refreshed(sender:)), for: .valueChanged)
        return r
        
    }()
    
    lazy var searchController = UISearchController(searchResultsController: tableViewController)
    
    private lazy var searchesDataSource = SearchTableDataSource(delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        
        eventsHandler?.onScreenReady()
    }
    
    func setupUi() {
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            tableView.contentInset = UIEdgeInsetsMake(UIApplication.shared.statusBarFrame.height, 0, 0, 0)
        }
        
        tableView.register(UINib(nibName: CityWeatherCell.theClassName, bundle: nil), forCellReuseIdentifier: CityWeatherCell.identifier)
        tableView.rowHeight = CityWeatherCell.height
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1)
        
        searchController.searchResultsUpdater = self
        
        tableView.addSubview(refreshControl)
    }
    
    fileprivate func selected(in dataSource: SearchTableDataSource, city: City) {
        searchController.isActive = false
        eventsHandler?.onAdd(city: city)
    }
    
    @objc func refreshed(sender: Any) {
        eventsHandler?.onUpdate()
    }
}

extension CitiesListViewController: CitiesScreen {
    
    func remove(cityIdx: Int) {
        cities.remove(at: cityIdx)
        let indexPath = IndexPath(row: cityIdx, section: 0)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }
    
    func add(city: City) {
        cities.append(city)
        tableView.beginUpdates()
        let indexPath = IndexPath(row: cities.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func set(cities: [City]) {
        self.cities = cities
        tableView.reloadData()
    }
    
    func showSearchedCityNotFoundMessage() {
        searchesDataSource.state = .notFound
        tableViewController.tableView.reloadData()
    }
    
    func offerForSearch(city: City) {
        searchesDataSource.state = .city(city: city)
        tableViewController.tableView.reloadData()
    }
    
    func showLoadingSearchedCity() {
        searchesDataSource.state = .loading
        tableViewController.tableView.reloadData()
    }
    
    func fullReload(cities: [City]) {
        
        view.isUserInteractionEnabled = false
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            
            self?.tableView.alpha = 0
            
        }, completion: { [weak self] completed in
            
            self?.cities = cities
            
            self?.tableView.reloadData()
            self?.view.isUserInteractionEnabled = true
            
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.tableView.alpha = 1    
            })
        })
    }
    
    func showErrorOnReload(message: String) {
        
        if refreshControl.isRefreshing {
            
            refreshControl.endRefreshing()
        }
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
}

extension CitiesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CityWeatherCell.identifier) as? CityWeatherCell else {
            fatalError("CityWeatherCell expected")
        }
        
        cell.cityNameLabel.text = cities[indexPath.row].name
        cell.cityWeatherLabel.text = cities[indexPath.row].temperatureToDisplay
        
        if let url = URL(string: cities[indexPath.row].icon) {
            cell.cityWeatherImage.sd_setImage(with: url)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete", handler: { action , indexPath in
            self.eventsHandler?.onDelete(cityIdx: indexPath.row)
        })
        
        deleteAction.backgroundColor = .red
        
        return [deleteAction]
    }
    
}


extension CitiesListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            return
        }
        
        eventsHandler?.onSearch(text: searchText)
    }
}

fileprivate protocol SearchTableDataSourceDelegate: class {
    func selected(in dataSource: SearchTableDataSource, city: City)
}

fileprivate class SearchTableDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    enum State {
        case loading
        case notFound
        case city(city: City)
        case empty
    }
    
    init(delegate: SearchTableDataSourceDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    var state: State = .empty
    
    weak var delegate: SearchTableDataSourceDelegate?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .empty:
            return 0
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch state {
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier)!
            cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 13)
            cell.textLabel?.text = "Loading..."
            cell.textLabel?.textColor = .lightGray
            return cell
            
        case .city(let city):
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CityWeatherCell.identifier) as? CityWeatherCell else {
                fatalError("CityWeatherCell expected")
            }
            
            cell.cityNameLabel.text = city.name
            cell.cityWeatherLabel.text = city.temperatureToDisplay
            
            if let url = URL(string: city.icon) {
                cell.cityWeatherImage.sd_setImage(with: url)
            }
            
            return cell
            
        case .notFound:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier)!
            cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 13)
            cell.textLabel?.text = "Not found"
            cell.textLabel?.textColor = .black
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier)!
            cell.textLabel?.text = nil
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch state {
        case .city(let city):
            delegate?.selected(in: self, city: city)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
