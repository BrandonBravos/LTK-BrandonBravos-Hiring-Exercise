//
//  DisplayViewController.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit

class DisplayViewController: UIViewController {

    // the sections we want to display and their assoicated indexPath.section
    private enum DisplaySections: Int {
        case postSection = 0, shopSection = 1, userSection = 2
    }
    
    private let displaySections: [DisplaySections] = [.postSection, .shopSection, .userSection]

    var collectionView: UICollectionView!
    private var viewModel: DisplayViewModel!
    
    // image view of the users avatar
    private let profileImageView = UIImageView()
    
    // a collection of views to animate for transitioning into the view
    public var animationViews: [UIView] = []
    
    let profileBar = UserFollowBarView()
    
    init(withUser user: Profile, withLtk ltk: LtkPost){
        self.viewModel = DisplayViewModel(user: user, ltk: ltk)
        super.init(nibName: nil, bundle: nil)
        setUpView()
        
    }
    
    override func viewDidLoad() {
    
        viewModel.fetchProductData { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.getUser().getProfileImage{[weak self] result in
            self?.profileBar.setProfileImage(result)
        }
        
        updateWithPostData()
    }
    
    private func updateWithPostData() {
        viewModel.getUserPostData {[weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    // remove the view
    @objc private func backButtonTapped(){
        self.modalTransitionStyle = .crossDissolve
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Delegate
extension DisplayViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // add our supplementary header view
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let blankView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                              withReuseIdentifier: BlankReusableCollectionView.reuseIdentifier,
                                                                              for: indexPath) as? BlankReusableCollectionView else {
            return BlankReusableCollectionView()
        }
        
        switch displaySections[indexPath.section] {
        case .postSection:
            return blankView
        case .shopSection:
            guard let shopThePicView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                                       withReuseIdentifier: ShopThePicHeaderView.reuseIdentifier, for: indexPath) as? ShopThePicHeaderView else {
                print("DisplayViewController: error dequeing ShopThePicHeaderView ")
                return ShopThePicHeaderView()
            }
            return shopThePicView
        case .userSection:
            guard let moreFromUserView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                                         withReuseIdentifier: MoreFromUserReusableView.reuseIdentifier,
                                                                                         for: indexPath) as? MoreFromUserReusableView else {
                return MoreFromUserReusableView()
            }
            viewModel.getProfilePicture { result in
                moreFromUserView.configure(withUserName: self.viewModel.getUser().displayName, withProfileImage: result)
                
            }
            return moreFromUserView
        }
    }

    // on press open safari
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        switch displaySections[indexPath.section] {
        case .postSection:
            return
        case .shopSection:
            if let url = URL(string: viewModel.getProductUrl(withIndexPath: indexPath)!) {
                UIApplication.shared.open(url)
            }
        case .userSection:
            guard let cell = collectionView.cellForItem(at: indexPath) as? LtkImageCell,
                     cell.imageView.image != nil else {
                print("DiscoveryViewController: Error getting LtkImageCell when selected")
                return
            }

            let user = viewModel.getUser()
            let displayViewController = DisplayViewController(withUser: user, withLtk: user.ltks[indexPath.row])
            var transitionController = TransitionImageController()
            transitionController.begin(fromView: self, fromImageView: cell.imageView, toNewView: displayViewController)

            // push the view controller
            navigationController?.pushViewController(displayViewController, animated: false)
            return
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard  scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.height) - 20 else {
            return
        }
        guard !viewModel.isLoading else { return }
        updateWithPostData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return displaySections.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if section > displaySections.count { return 0}
        switch displaySections[section] {
        case .postSection: return 1
        case .shopSection: return viewModel.getLoadedProductsCount()
        case .userSection: return viewModel.getUser().ltks.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch displaySections[indexPath.section] {
        case .postSection:
            guard let postCell = collectionView.dequeueReusableCell(withReuseIdentifier: LtkImageCell.reuseIdentifier,
                                                                    for: indexPath) as? LtkImageCell else {
                print("DisplayViewController: Unable to dequeue cell LtkImageCell \(indexPath)")
                return LtkImageCell()
            }
            viewModel.getPostImage { image in
                postCell.setImageView(image)
            }
            postCell.imageView.layer.borderWidth = 0
            return postCell
        case .shopSection:
            guard let shopCell = collectionView.dequeueReusableCell(withReuseIdentifier: LtkImageCell.reuseIdentifier,
                                                                    for: indexPath) as? LtkImageCell else {
                print("DisplayViewController: Unable to dequeue cell LtkImageCell \(indexPath)")
                return LtkImageCell()
            }
            viewModel.getProductImage(withIndex: indexPath) { image in
                shopCell.setImageView(image)
            }
            shopCell.imageView.layer.borderWidth = 0.35
            shopCell.imageView.layer.borderColor = UIColor.lightGray.cgColor
            return shopCell

        case .userSection:
            guard let userCell = collectionView.dequeueReusableCell(withReuseIdentifier: LtkImageCell.reuseIdentifier,
                                                                    for: indexPath) as? LtkImageCell else {
                print("DisplayViewController: Unable to dequeue cell LtkImageCell \(indexPath)")
                return LtkImageCell()
            }
            viewModel.getUser().ltks[indexPath.row].getPostImage { image in
                userCell.setImageView(image)
            }
            return userCell
        }
    }
}

extension DisplayViewController: WaterfallLayoutDelegate {
    func collectionViewLayout(for section: Int) -> WaterfallLayout.Layout {
        let columnCount = 4
        switch displaySections[section] {
        case .postSection:
            return .flow(column: 1)
        case .shopSection:
            return .flow(column: Int(columnCount))
        case .userSection:
            return .waterfall(column: 2, distributionMethod: .equal)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout: WaterfallLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let desiredScreenWidth = UIScreen.main.bounds.width - layout.sectionInset.left - layout.sectionInset.right

        // noticed a strange correlation with width and height, if you set height to 80, height is multiplied by 5
        switch displaySections[indexPath.section] {
        case .postSection:
            return CGSize(width: desiredScreenWidth, height: viewModel.ltk.getHeightAspectRatio(withWidth: desiredScreenWidth) - 30)
        case .shopSection:
            return CGSize(width: desiredScreenWidth/5, height: desiredScreenWidth / 5)
        case .userSection:
            return CGSize(width: desiredScreenWidth/2, height: viewModel.getUser().ltks[indexPath.row].getHeightAspectRatio(withWidth: desiredScreenWidth/2))
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout: WaterfallLayout, headerHeightFor section: Int) -> CGFloat? {
        switch displaySections[section] {
        case .postSection:
            return 0
        case .shopSection:
            return 80
        case .userSection:
            return 200
        }
    }
}

// MARK: Layout
extension DisplayViewController {
    func setUpView() {
        view.backgroundColor = .clear
        let headearBarHeight: CGFloat = 45
        let headerView = HeaderSearchLabelView(withBackButton: true)
        headerView.backgroundColor = .white
        headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchDown)
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

        let profileBarHeight: CGFloat = 55.0
        profileBar.setUsername(viewModel.getUser().displayName)
        profileBar.backgroundColor =  #colorLiteral(red: 0.9373, green: 0.9373, blue: 0.9373, alpha: 1) /* #efefef */
        view.addSubview(profileBar)
        profileBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileBar.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 5),
            profileBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileBar.heightAnchor.constraint(equalToConstant: profileBarHeight )
        ])

        let layout = WaterfallLayout()
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.headerHeight = 80.0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.register(LtkImageCell.self,
                                forCellWithReuseIdentifier: LtkImageCell.reuseIdentifier)
        collectionView.register(BlankReusableCollectionView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: BlankReusableCollectionView.reuseIdentifier)
        collectionView.register(ShopThePicHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ShopThePicHeaderView.reuseIdentifier)
        collectionView.register(MoreFromUserReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MoreFromUserReusableView.reuseIdentifier)
        collectionView.register(BlankCollectionViewCell.self,
                                forCellWithReuseIdentifier: BlankCollectionViewCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: profileBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80)
        ])
        animationViews.append(collectionView)
        animationViews.append(profileBar)
        for view in animationViews {
            view.alpha = 0
        }
    }
}
