//
//  SelectedUsersCollectionViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 21.02.2022..
//
import UIKit

class SelectedUsersCollectionViewCell: UICollectionViewCell, BaseView {
    
    static let reuseIdentifier: String = "SelectedUsersCollectionViewCell"

    let imageView = UIImageView()
    let closeImageView = UIImageView()
    let firstLetterLabel = CustomLabel(text: "Ž", textSize: 20, textColor: .white, fontName: .MontserratExtraBold, alignment: .center)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addSubviews() {
        addSubview(imageView)
        addSubview(firstLetterLabel)
        addSubview(closeImageView)
    }
    
    func styleSubviews() {
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        
        closeImageView.image = UIImage(named: "deleteCell")
    }
    
    func positionSubviews() {
        imageView.fillSuperview()
        firstLetterLabel.fillSuperview()
        closeImageView.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    func updateCell(user: User) {
        firstLetterLabel.text = user.displayName?.prefix(1).uppercased()
        let url = URL(string: //user.avatarUrl ?? avatarUrl is not working now
                      "https://c.tenor.com/_XivCIgUF90AAAAd/bounce-boob.gif")
        
        imageView.kf.setImage(with: url)
    }
}
