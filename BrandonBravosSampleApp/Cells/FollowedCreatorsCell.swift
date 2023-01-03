//
//  FollowedCreatorsCell.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/17/22.
//

import UIKit

class FollowedCreatorsCell: UICollectionViewCell {
    static let reuseIdentifier = "FollowedCreatorsCell"

    private var users: [Profile] = []

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProfileArray(profiles: [Profile]) {
        self.users = profiles
        collectionView.reloadData()
    }

    func setUpView() {
        collectionView.register(FollowingCell.self, forCellWithReuseIdentifier: FollowingCell.reuseIdentifier)
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

extension FollowedCreatorsCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 4.3, height: self.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let followingCell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowingCell.reuseIdentifier, for: indexPath) as? FollowingCell else {
            let cell = FollowingCell()
            return cell
        }
        
        followingCell.configure(profile: users[indexPath.row])
        return followingCell
        
    }
    
}

private class FollowingCell: UICollectionViewCell {
    static let reuseIdentifier = "FollowingCell"
    let profileImageView = UIImageView()
    let profileUserNameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpViews()
    }

    func configure(profile: Profile) {
        profile.getProfileImage { [weak self] result in
            DispatchQueue.main.async {
                self?.profileImageView.image = result
                self?.profileUserNameLabel.text = profile.displayName
            }
        }
    }
    
    private func setUpViews() {
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 85 / 2
        addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.widthAnchor.constraint(equalTo: heightAnchor, constant: -15),
            profileImageView.heightAnchor.constraint(equalTo: heightAnchor, constant: -15)
        ])

        profileUserNameLabel.textAlignment = .center
        profileUserNameLabel.font = UIFont.montserratFont(withMontserrat: .regular, withSize: 12)
        addSubview(profileUserNameLabel)
        profileUserNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileUserNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            profileUserNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileUserNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            profileUserNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
