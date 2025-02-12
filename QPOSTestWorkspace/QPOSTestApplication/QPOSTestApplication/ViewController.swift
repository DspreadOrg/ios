//
//  ViewController.swift
//  QPOSTestApplication
//
//  Created by Filipe Rogério Canzi da Silva on 12/02/25.
//

import UIKit
import QPOSTestFramework

extension ViewController {
    
    @objc open func button1Tapped() {
        POSManager.startScanning(scanningInterval: 10)
    }
    
    @objc open func button2Tapped() {
        guard POSManager.hasConnectedDevice else {
            print("You must connect the device before starting the trade.")
            return
        }
        
        let tradeData = POSTradeData(
            paymentAmount: 10.00,
            currencyCode: "840",
            transactionType: .GOODS,
            tradeMode: .SWIPE_TAP_INSERT_CARD_NOTUP)
        
        POSManager.startTrade(tradeData: tradeData)
    }
    
    @objc open func button3Tapped() {
        print("Button Test was Tapped")
    }
}

open class ViewController: UIViewController {
    
    public let imageStackView = UIStackView()
    public let imageView1 = UIImageView()
    public let imageView2 = UIImageView()
    
    public let labelStackView = UIStackView()
    public let label1 = UILabel()
    public let label2 = UILabel()
    public let label3 = UILabel()
    
    public let buttonStackView = UIStackView()
    public let button1 = UIButton()
    public let button2 = UIButton()
    public let button3 = UIButton()
    
    public var POSManager = PayologyPOSManager()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureAutoLayout()
        
        configureStackViews()
        
        configureImageViews()
        configureLabels()
        configureButtons()
    }
    
    open func configureAutoLayout() {
        
        view.addSubview(imageStackView)
        view.addSubview(labelStackView)
        view.addSubview(buttonStackView)
        
        imageStackView.addArrangedSubview(imageView1)
        imageStackView.addArrangedSubview(imageView2)
        
        labelStackView.addArrangedSubview(label1)
        labelStackView.addArrangedSubview(label2)
        labelStackView.addArrangedSubview(label3)
        
        buttonStackView.addArrangedSubview(button1)
        buttonStackView.addArrangedSubview(button2)
        buttonStackView.addArrangedSubview(button3)
        
        imageStackView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeGuide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            imageStackView.topAnchor.constraint(equalToSystemSpacingBelow: safeGuide.topAnchor, multiplier: 2),
            imageStackView.widthAnchor.constraint(equalTo: safeGuide.widthAnchor, multiplier: 0.9),
            imageStackView.heightAnchor.constraint(equalToConstant: 300),
            imageStackView.centerXAnchor.constraint(equalTo: safeGuide.centerXAnchor),
            
            labelStackView.topAnchor.constraint(equalToSystemSpacingBelow: imageStackView.bottomAnchor, multiplier: 2),
            labelStackView.widthAnchor.constraint(equalTo: safeGuide.widthAnchor, multiplier: 0.9),
            labelStackView.centerXAnchor.constraint(equalTo: safeGuide.centerXAnchor),
            
            buttonStackView.topAnchor.constraint(equalToSystemSpacingBelow: labelStackView.bottomAnchor, multiplier: 2),
            buttonStackView.widthAnchor.constraint(equalTo: safeGuide.widthAnchor, multiplier: 0.9),
            buttonStackView.centerXAnchor.constraint(equalTo: safeGuide.centerXAnchor),
        ])
        
        for imageView in imageStackView.arrangedSubviews {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalTo: imageStackView.heightAnchor).isActive = true
            imageView.widthAnchor.constraint(equalTo: imageStackView.widthAnchor, multiplier: 0.45).isActive = true
        }
        
        for label in labelStackView.arrangedSubviews {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.widthAnchor.constraint(equalTo: labelStackView.widthAnchor).isActive = true
        }
        
        for button in buttonStackView.arrangedSubviews {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalTo: buttonStackView.widthAnchor).isActive = true
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }
    
    open func configureStackViews() {
        
        imageStackView.axis = .horizontal
        imageStackView.spacing = 8
        imageStackView.distribution = .equalCentering
        imageStackView.alignment = .center
        
        labelStackView.axis = .vertical
        labelStackView.spacing = 16
        
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 16
    }
    
    open func configureImageViews() {
        
        imageView1.image = UIImage(systemName: "paperclip")
        imageView1.contentMode = .scaleAspectFit
        
        imageView2.image = UIImage(systemName: "paperclip")
        imageView2.contentMode = .scaleAspectFit
        
    }
    
    open func configureLabels() {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 16),
            .foregroundColor : UIColor.black,
            .paragraphStyle : paragraphStyle
        ]
        
        label1.attributedText = .init(string: "Label 1", attributes: attributes)
        label2.attributedText = .init(string: "Label 2", attributes: attributes)
        label3.attributedText = .init(string: "Label 3", attributes: attributes)
    }
    
    open func configureButtons() {
        
        let configuration = UIButton.Configuration.filled()
        
        button1.configuration = configuration
        button2.configuration = configuration
        button3.configuration = configuration
        
        button1.configuration?.title = "Search for MPOS Device (CR100)"
        button2.configuration?.title = "Perform Trade"
        button3.configuration?.title = "Button Test"
        
        button1.addTarget(self, action: #selector(button1Tapped), for: .touchUpInside)
        button2.addTarget(self, action: #selector(button2Tapped), for: .touchUpInside)
        button3.addTarget(self, action: #selector(button3Tapped), for: .touchUpInside)
    }
}

extension UIView {
    
    public func disableSubviewsAutoresizing() {
        for subview in subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
