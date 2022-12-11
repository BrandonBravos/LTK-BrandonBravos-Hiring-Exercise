//
//  DisplayViewController.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit

class DisplayViewController: UIViewController {

    lazy var collectionView: UICollectionView = {
         let layout = UICollectionViewFlowLayout()
         layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 20, right: 10)
         let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
         cv.delegate = self
         cv.dataSource = self
         cv.register(ShopThePicView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ShopThePicView.reuseIdentifier)
        cv.register(LtkImageCell.self, forCellWithReuseIdentifier: LtkImageCell.reuseIdentifier)
         return cv
     }()
     
    private var viewModel: DisplayViewModel!
    
    // image view of the users avatar
    private let profileImageView = UIImageView()

    // a collection of views to animate for transitioning into the view
    private var animationViews: [UIView] = []
    
    // an image that translates from over an image to our post image
    private let transitionImage = UIImageView()

    init(withUser user: Profile){
        self.viewModel = DisplayViewModel(user: user)
        super.init(nibName: nil, bundle: nil)
        setUpView()
        
    }
    
    override func viewDidLoad() {
        viewModel.fetchData { [weak self] in
            DispatchQueue.main.async {
                self?.profileImageView.image = self?.viewModel.getProfilePicture()
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
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ShopThePicView.reuseIdentifier, for: indexPath) as! ShopThePicView
        if indexPath.section == 1{ view.config() }
        
        return view
    }
    
    // on press open safari
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1{
            if let url = URL(string: viewModel.getProductUrl(withIndexPath: indexPath)!) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    // hide our supplementary view if not in section 0
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height = section == 1 ? 55.0 : 0.0
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        
        if indexPath.section == 0{
            let height = viewModel.getPostImage().getHeightAspectRatio(withWidth: width)
            
            return CGSize(width: width - 20, height: height)
        } else {
            return CGSize(width: 80, height: 80)

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItems = section == 0 ? 1 : viewModel.getCount()
        return numberOfItems
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LtkImageCell.reuseIdentifier, for: indexPath) as! LtkImageCell

        if indexPath.section == 0{
            cell.imageView.image = viewModel.getPostImage()
            cell.imageView.layer.borderWidth = 0
        }else{
            cell.imageView.image = viewModel.getProductImage(withIndex: indexPath)
            cell.imageView.layer.borderColor = UIColor.darkGray.cgColor
            cell.imageView.layer.cornerRadius = 15
            cell.imageView.layer.borderWidth = 0.5
        }
        
        return cell
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
        
        let profileBar = UIView()
        profileBar.backgroundColor = .lightGray
        view.addSubview(profileBar)
        profileBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileBar.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 5),
            profileBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileBar.heightAnchor.constraint(equalToConstant: profileBarHeight )
        ])
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = (profileBarHeight - 10) / 2
        profileImageView.image = viewModel.getProfilePicture()
         profileBar.addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: profileBar.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: profileBar.leadingAnchor, constant: 15),
            profileImageView.widthAnchor.constraint(equalToConstant: profileBarHeight - 10),
            profileImageView.heightAnchor.constraint(equalToConstant: profileBarHeight - 10),

        ])
        
        let profileUserTextLabel = UILabel()
        profileUserTextLabel.font = UIFont.montserratFont(withMontserrat: .medium, withSize: 15)
        profileUserTextLabel.text = viewModel.getUser().displayName
        profileBar.addSubview(profileUserTextLabel)
        profileUserTextLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileUserTextLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            profileUserTextLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            profileUserTextLabel.heightAnchor.constraint(equalToConstant: profileBarHeight),
            profileUserTextLabel.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        
        view.addSubview(collectionView)
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



