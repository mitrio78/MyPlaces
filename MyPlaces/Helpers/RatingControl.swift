//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Дмитрий Гришечко on 10.01.2022.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    //MARK: Properties
    var rating = 0 {
        didSet {
            updateButtonSelectedState()
        }
    }
    private var ratingButtons = [UIButton]()
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    //MARK: Button Action
    
    @objc func ratingButtonTapped (button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else {return}
        // Calculate rating of the selected button
        let selectedRating = index + 1
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    //MARK: Private Methods
    
    private func setupButtons() {
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        //load button image
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar",
                                 in: bundle,
                                 compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar",
                                in: bundle,
                                compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar",
                                      in: bundle,
                                      compatibleWith: self.traitCollection)
        for _ in 0..<starCount {
            //create button
            let button = UIButton()
            //setButton Images
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            //constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            //Setup Button method
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            //Add button to stack view
            addArrangedSubview(button)
            //Add a new button in array
            ratingButtons.append(button)
        }
        updateButtonSelectedState()
    }
    private func updateButtonSelectedState() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
