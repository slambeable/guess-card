//
//  CardGameViewController.swift
//  GuessСard
//
//  Created by Андрей Евдокимов on 21.01.2022.
//

import UIKit

class CardGameViewController: UIViewController {

    @IBOutlet var leftCardImage: UIImageView!
    @IBOutlet var rightCardImage: UIImageView!
    
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    
    @IBOutlet var resultLabel: UILabel!
    
    @IBOutlet var loadingCardsActivityIndicator: UIActivityIndicatorView!
    
    private let textForAnswer = (
        rightAnswer: "Вы отгадали",
        errorAnswer: "Вы ошиблись"
    )
    
    private var randomButton: CardSelectKeys?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultLabel.isHidden = true
        leftCardImage.isHidden = true
        rightCardImage.isHidden = true
        leftButton.isHidden = true
        rightButton.isHidden = true
        
        loadingCardsActivityIndicator.hidesWhenStopped = true
        loadingCardsActivityIndicator.startAnimating()
        
        getRandomCard()
        
        DispatchQueue.global().async {
            self.prepareData()
        }
    }
    
    
    @IBAction func choseCard(_ sender: UIButton) {
        if let chosenButtonId = sender.restorationIdentifier {
            guard let randomNumber = randomButton?.rawValue else { return }

            if chosenButtonId == randomNumber {
                resultLabel.text = textForAnswer.rightAnswer
                resultLabel.textColor = UIColor(ciColor: .green)
            } else {
                resultLabel.text = textForAnswer.errorAnswer
                resultLabel.textColor = UIColor(ciColor: .red)
            }
            
            resultLabel.isHidden = false
            
            leftButton.isHidden = true
            rightButton.isHidden = true
        }
    }
    
    @IBAction func closeGameScreen(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    private func getRandomCard() {
        let buttons: [CardSelectKeys] = [.leftButton, .rightButton]
        
        randomButton = buttons.randomElement() ?? .leftButton
    }
    
    private func prepareData() {
        let completionAfterFetchCard = { () in
            if let leftCardUrl = DataManager.shared.cards.first?.image,
               let rightCardUrl = DataManager.shared.cards.last?.image {
                guard let leftImageData = try? Data(contentsOf: leftCardUrl) else { return }
                guard let rightImageData = try? Data(contentsOf: rightCardUrl) else { return }

                DispatchQueue.main.async {
                    self.loadingCardsActivityIndicator.stopAnimating()
                    
                    self.leftCardImage.image = UIImage(data: leftImageData)
                    self.rightCardImage.image = UIImage(data: rightImageData)
                    
                    self.leftCardImage.isHidden = false
                    self.rightCardImage.isHidden = false
                    
                    self.leftButton.isHidden = false
                    self.rightButton.isHidden = false
                }
            }
        }

        let completionAfterFetchDeck = { () in
            DataManager.shared.fetchCards(with: completionAfterFetchCard)
        }

        DataManager.shared.fetchDeck(with: completionAfterFetchDeck)
    }
}

extension CardGameViewController {
    enum CardSelectKeys: String {
        case leftButton
        case rightButton
    }
}
