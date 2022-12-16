//
//  DisplayViewController.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit

class DisplayViewController: UIViewController {

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
         cv.register(MoreFromUserReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MoreFromUserReusableView.reuseIdentifier)
        cv.register(LtkImageCell.self, forCellWithReuseIdentifier: LtkImageCell.reuseIdentifier)
         return cv
     }()
    
//    lazy var collectionView: UICollectionView = {
//        let layout = WaterfallLayout()
//        layout.delegate = self
//        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        layout.minimumLineSpacing = 8.0
//        layout.minimumInteritemSpacing = 8.0
//        layout.headerHeight = 80.0
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.delegate = self
//        cv.dataSource = self
//        return cv
//    }()
    
    
    private var viewModel: DisplayViewModel!
    
    // image view of the users avatar
    private let profileImageView = UIImageView()

    // a collection of views to animate for transitioning into the view
    private var animationViews: [UIView] = []
    
    // an image that translates from over an image to our post image
    private let transitionImage = UIImageView()

    let profileBar = UserFollowBarView()

    init(withUser user: Profile){
        self.viewModel = DisplayViewModel(user: user)
        super.init(nibName: nil, bundle: nil)
        setUpView()
        
    }
    
    
    
    override func viewDidLoad() {
        viewModel.fetchData { [weak self] in
            DispatchQueue.main.async {
                self?.profileBar.setProfileImage(self?.viewModel.getProfilePicture())
                self?.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        beginTranslationAnimation()
    }
    
    
    // starts the transitional animation. Animates our view from one end to hover over our post image
    private func beginTranslationAnimation(){
        // this code perfectly aligns the view but doesnt work everytime
        //        let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as! LtkImageCell
        //        let center = cell.imageView.superview?.convert( cell.imageView.frame.origin, to: nil)
        //        let frame = cell.imageView.frame

        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: { [self] in
            self.transitionImage.layer.cornerRadius = 0
            self.view.backgroundColor = .white
            self.transitionImage.frame = CGRect(x: 6, y: 163, width: UIScreen.main.bounds.width - 12, height: self.viewModel.getPostImage().getHeightAspectRatio(withWidth:  UIScreen.main.bounds.width) - 20)
       
            // self.transitionImage.frame = CGRect(x: center!.x, y: center!.y, width: frame.width, height: frame.height)

        }, completion: { _ in
           self.view.layoutIfNeeded()
           self.animateTransitionFadeIn()
        })
    }
  
    
   // fades in the views and removes the transition image
   private func animateTransitionFadeIn(){
        let transitionAlpha = 1.0
               UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                   for view in self.animationViews{
                       view.alpha = transitionAlpha
                   }
               }, completion: { _ in
                   self.view.layoutIfNeeded()
                   self.transitionImage.alpha = 0
               })
    }
    
    
    /// creates the transition image and begins by covering it over the previous image at the specified points.
    public func createTransitionAnimationImage(withImage image: UIImage, withCenter center: CGPoint, withFrame frame: CGRect){
        transitionImage.image = image
        transitionImage.clipsToBounds = true
        transitionImage.layer.cornerRadius = 15
        transitionImage.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        transitionImage.center = CGPoint(x: center.x + frame.width/2, y: center.y + frame.height/2)
        view.addSubview(transitionImage)
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
extension DisplayViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
   
    // add our supplementary header view
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let blankView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BlankReusableCollectionView.reuseIdentifier, for: indexPath) as! BlankReusableCollectionView
         
        switch displaySections[indexPath.section] {
        case .postSection:
            return blankView
        case .shopSection:
            let shopThePicView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ShopThePicHeaderReusableView.reuseIdentifier, for: indexPath) as! ShopThePicHeaderReusableView
            return shopThePicView
        case .userSection:
            let moreFromUserView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MoreFromUserReusableView.reuseIdentifier, for: indexPath) as! MoreFromUserReusableView
            moreFromUserView.configure(withUserName: viewModel.getUser().displayName, withProfileImage: viewModel.getProfilePicture())
            return moreFromUserView
        }
    }
    
    // on press open safari
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1{
            if let url = URL(string: viewModel.getProductUrl(withIndexPath: indexPath)!) {
                UIApplication.shared.open(url)
            }
        }
    }
    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return displaySections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section > displaySections.count { return 0}
        switch displaySections[section]{
        case .postSection: return 1
        case .shopSection: return viewModel.getCount()
        case .userSection: return viewModel.getUser().ltks.count
        }
    }
  
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch displaySections[indexPath.section]{
            
        case .postSection:
            let postCell = collectionView.dequeueReusableCell(withReuseIdentifier: LtkImageCell.reuseIdentifier, for: indexPath) as! LtkImageCell
            postCell.setImageView(viewModel.getPostImage())
            postCell.imageView.layer.borderWidth = 0
            return postCell
            
        case .shopSection:
            let shopCell = collectionView.dequeueReusableCell(withReuseIdentifier: LtkImageCell.reuseIdentifier, for: indexPath) as! LtkImageCell
            shopCell.setImageView(viewModel.getProductImage(withIndex: indexPath))
            shopCell.imageView.layer.borderWidth = 0.35
            shopCell.imageView.layer.borderColor = UIColor.lightGray.cgColor
            return shopCell
            
        case .userSection:
            let userCell = collectionView.dequeueReusableCell(withReuseIdentifier: LtkImageCell.reuseIdentifier, for: indexPath) as! LtkImageCell
            userCell.setImageView(viewModel.getPostImage())
            return userCell
        }
    
    }
}

extension DisplayViewController: WaterfallLayoutDelegate{
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
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let desiredScreenWidth = UIScreen.main.bounds.width - layout.sectionInset.left - layout.sectionInset.right
        
        // noticed a strange correlation with width and height, if you set height to 80, height is multiplied by 5
        switch displaySections[indexPath.section] {
        case .postSection:
            return CGSize(width: 80, height: viewModel.getPostImage().getHeightAspectRatio(withWidth: desiredScreenWidth)/5)
        case .shopSection:
            return CGSize(width: 80, height: (UIScreen.main.bounds.width - 20) / 5)
        case .userSection:
            return CGSize(width: 80, height: (viewModel.getUser().ltks[indexPath.row].heroImage?.getHeightAspectRatio(withWidth: desiredScreenWidth))!/5)
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
extension DisplayViewController{
    func setUpView(){
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
        profileBar.backgroundColor = .lightGray
        view.addSubview(profileBar)
        profileBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileBar.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 5),
            profileBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileBar.heightAnchor.constraint(equalToConstant: profileBarHeight )
        ])
        
    
        view.addSubview(collectionView)
        collectionView.register(BlankReusableCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BlankReusableCollectionView.reuseIdentifier)
        collectionView.register(ShopThePicHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ShopThePicHeaderReusableView.reuseIdentifier)
        collectionView.register(MoreFromUserReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MoreFromUserReusableView.reuseIdentifier)

        collectionView.register(BlankCollectionViewCell.self, forCellWithReuseIdentifier: BlankCollectionViewCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: profileBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80)
        ])
        
        animationViews.append(collectionView)
        animationViews.append(profileBar)

        for view in animationViews{ view.alpha = 0 }
    }
}



