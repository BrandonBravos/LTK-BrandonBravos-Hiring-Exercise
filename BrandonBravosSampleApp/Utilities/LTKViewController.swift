//
//  LTKViewController.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 1/13/23.
//

import Foundation
import UIKit

class LTKViewController: UIViewController{
    
    public let headerView = HeaderSearchLabelView()
    public let headearBarHeight: CGFloat = 45
    
    public var hasLoadIndicator = true {
        didSet{
            self.loadIndicator.alpha = hasLoadIndicator ? 1 : 0
        }
    }
    
    // a custom loading indicator
    public let loadIndicator = LtkLoadIndicator()

    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        print(view.tag)
        view.tag = 12
        setUpView()
    }
    
    private func setUpView(){
        view.backgroundColor = .white
        let headerView = HeaderSearchLabelView()
        headerView.searchView.delegate = self
        headerView.backgroundColor = .white
        headerView.searchView.layer.cornerRadius = headearBarHeight / 2
        headerView.isUserInteractionEnabled = true
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headearBarHeight)
        ])

        loadCollectionView()

        view.addSubview(loadIndicator)
        loadIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: headearBarHeight),
            loadIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadIndicator.widthAnchor.constraint(equalToConstant: 55),
            loadIndicator.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    func loadCollectionView(){
        
       let layout = setCollectionViewLayout()
       collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView.register(SimpleHeaderReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SimpleHeaderReusableView.reuseIdentifier)
        collectionView.register(BlankCollectionViewCell.self,
                                forCellWithReuseIdentifier: BlankCollectionViewCell.reuseIdentifier)
        collectionView.register(FollowedCreatorsCell.self,
                                forCellWithReuseIdentifier: FollowedCreatorsCell.reuseIdentifier)
        collectionView.register(FullDisplayCell.self,
                                forCellWithReuseIdentifier: FullDisplayCell.reuseIdentifier)
        
        collectionView.register(LtkImageCell.self, forCellWithReuseIdentifier: LtkImageCell.reuseIdentifier)
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: headearBarHeight),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }
    
    func setCollectionViewLayout() -> UICollectionViewLayout{
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 45)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
        layout.minimumLineSpacing = 100
        
        return layout
    }
}


extension LTKViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
}

extension LTKViewController: SearchDelegate{
    func searchEdited(searchTextField: UITextField, withText text: String) {
       
    }
    
    func searchSelected(){
        let searchViewController = SearchViewController()
        searchViewController.view.backgroundColor = .white
        navigationController?.pushViewController(searchViewController, animated: false)
    }
    
}


