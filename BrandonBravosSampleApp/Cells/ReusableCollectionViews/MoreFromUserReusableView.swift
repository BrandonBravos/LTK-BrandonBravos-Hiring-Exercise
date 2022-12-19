//
//  File.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit


// a reusable header for our LTK post
class MoreFromUserReusableView: UICollectionReusableView{
    static let reuseIdentifier = "MoreFromUserReusableView"
    
    let centerLabel = UILabel()
    let userNameLabel = UILabel()
    let profileImageView = UIImageView()

    func configure(withUserName username: String, withProfileImage image: UIImage?){
        DispatchQueue.main.async {
            self.userNameLabel.text = username.uppercased()
        guard let image = image else {
            print("No profile image")
            return
        }
            self.profileImageView.image = image
        }

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
           
        
        userNameLabel.font = UIFont.montserratFont(withMontserrat: .regular, withSize: 16)
        userNameLabel.textAlignment = .center
        userNameLabel.sizeToFit()
        addSubview(userNameLabel)
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            userNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            userNameLabel.widthAnchor.constraint(equalToConstant: 400),
          //  userNameLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        centerLabel.text = "MORE FROM"
        centerLabel.font = UIFont.montserratFont(withMontserrat: .light, withSize: 10)
        centerLabel.textAlignment = .center
        centerLabel.backgroundColor = .white
        centerLabel.sizeToFit()
        addSubview(centerLabel)
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerLabel.bottomAnchor.constraint(equalTo: userNameLabel.topAnchor, constant: -5),
            centerLabel.widthAnchor.constraint(equalToConstant: 80),
        ])
        
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 75 / 2
        addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.bottomAnchor.constraint(equalTo: centerLabel.topAnchor, constant: -10),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 75),
            profileImageView.heightAnchor.constraint(equalToConstant: 75),
        
        ])
        addSideBars()
    }
 
    func addSideBars(){
        let sideBar = UIView()
        sideBar.backgroundColor = .gray
        addSubview(sideBar)
        sideBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sideBar.centerYAnchor.constraint(equalTo: centerLabel.centerYAnchor),
            sideBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            sideBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            sideBar.heightAnchor.constraint(equalToConstant: 0.35)
        ])
        
        bringSubviewToFront(centerLabel)
    }
}
