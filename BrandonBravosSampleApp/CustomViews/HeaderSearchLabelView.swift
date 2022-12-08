//
//  jkdh.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit

class HeaderSearchLabelView: UIView {

    public let searchView = SearchView()
    public let backButton = UIButton()

    private var hasBackButton = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        isUserInteractionEnabled = true

        setUpView()
    }
    
    init(withBackButton: Bool){
        super.init(frame: .zero)
        self.hasBackButton = withBackButton
        setUpView()
    }
    
    
    
    private func setUpView(){
        

        if hasBackButton{
            backButton.setImage(UIImage(named: "back_arrow_icon"), for: .normal)
            addSubview(backButton)
            backButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
                backButton.widthAnchor.constraint(equalToConstant: 45),
                backButton.heightAnchor.constraint(equalToConstant: 45)
            ])
        }
        
        let logoImageView = UIImageView()
        logoImageView.contentMode = .scaleAspectFit

        logoImageView.image = UIImage(named: "ltk_logo")
        self.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: topAnchor),
            logoImageView.heightAnchor.constraint(equalTo: heightAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 75)

        ])

        if hasBackButton{
            let anchor = logoImageView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 2)
            anchor.isActive = true
        } else {
            let anchor = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
            anchor.isActive = true

        }


        addSubview(searchView)
        searchView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchView.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 5),
            searchView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            searchView.topAnchor.constraint(equalTo: topAnchor),
            searchView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        

        
    
    }
    
    @objc private func didTap(){
        print("Tapped the button")
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

