//
//  BlankViewController.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit

class BlankViewController: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}




// MARK: LAYOUT TEST
/*
    private enum DisplaySections: Int{
        case postSection = 0, shopSection = 1, userSection = 2
    }

    private let displaySections:[DisplaySections] = [.postSection,.shopSection,.userSection]

    lazy var collectionView: UICollectionView = {
        let layout = WaterfallLayout()
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.headerHeight = 80.0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpView()
    }


}

extension BlankViewController:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return displaySections.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section > displaySections.count { return 0}
        switch displaySections[section]{
        case .postSection: return 1
        case .shopSection: return 10
        case.userSection: return 10
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BlankCollectionViewCell.reuseIdentifier, for: indexPath) as! BlankCollectionViewCell

        switch displaySections[indexPath.section] {
        case .postSection:
            cell.backgroundColor = .systemPink
        case .shopSection:
            cell.backgroundColor = .systemCyan
        case .userSection:
            cell.backgroundColor = .systemMint
        }
        return cell
    }


}


extension BlankViewController: WaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var heightArray = [CGFloat]()
        for _ in 0...12{
            let randomHeights = CGFloat.random(in: 80...150)
            heightArray.append(randomHeights)
        }

        switch displaySections[indexPath.section] {
        case .postSection:
            return CGSize(width: 80, height: UIScreen.main.bounds.height/10)
        case .shopSection:
            return CGSize(width: 80, height: (UIScreen.main.bounds.width - 20) / 5)
        case .userSection:
            return CGSize(width: 80, height: heightArray[indexPath.row])
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout: WaterfallLayout, headerHeightFor section: Int) -> CGFloat? {
        switch displaySections[section] {
        case .postSection:
            return 0
        case .shopSection:
            return 80
        case .userSection:
            return 120
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BlankReusableCollectionView.reuseIdentifier, for: indexPath) as! BlankReusableCollectionView
        header.configure()
        return header
    }

    func collectionViewLayout(for section: Int) -> WaterfallLayout.Layout {
        let columnCount = 5
        switch displaySections[section] {
        case .postSection:
            return .flow(column: 1)
        case .shopSection:
            return .flow(column: Int(columnCount))
        case .userSection:
            return .waterfall(column: 2, distributionMethod: .equal)
        }
    }

}

//MARK: Layout
extension BlankViewController{

    private func setUpView(){
        let headearBarHeight: CGFloat = 45
        let headerView = HeaderSearchLabelView(withBackButton: true)
//        headerView.backButton.addTarget(self, action: #selector(headerBackButtonTapped), for: .touchDown)
        headerView.backgroundColor = .white
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

        let userTitle = UserFollowBarView()
        userTitle.backgroundColor = .systemGray
        view.addSubview(userTitle)
        userTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userTitle.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 2),
            userTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            userTitle.heightAnchor.constraint(equalToConstant: 55)
        ])


        collectionView.register(BlankReusableCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BlankReusableCollectionView.reuseIdentifier)
        collectionView.register(BlankCollectionViewCell.self, forCellWithReuseIdentifier: BlankCollectionViewCell.reuseIdentifier)
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: userTitle.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }
*/
