import UIKit

class BPMIndicatorView: UIView {
    
    private let yellowBar = UIView()
    private let greenBar = UIView()
    private let redBar = UIView()
    private let marker = UIView()
    
    private let label30 = UILabel()
    private let label69 = UILabel()
    private let label99 = UILabel()
    private let label130 = UILabel()
    
    var bpm: CGFloat = 100 {
        didSet {
            layoutBars()
        }
    }
    
    private let rangeMin: CGFloat = 30
    private let rangeMax: CGFloat = 130
    
    private let barHeight: CGFloat = 12
    private let markerWidth: CGFloat = 2
    private let labelTopPadding: CGFloat = 8
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        [yellowBar, greenBar, redBar, marker].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        yellowBar.backgroundColor = .systemYellow
        greenBar.backgroundColor = .systemGreen
        redBar.backgroundColor = .systemRed
        
        marker.backgroundColor = .black
        marker.layer.cornerRadius = 1
        
        // Setup labels
        [label30, label69, label99, label130].forEach {
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .darkGray
            $0.sizeToFit()
            addSubview($0)
        }
        
        label30.text = "30"
        label69.text = "69"
        label99.text = "99"
        label130.text = "130"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutBars()
        layoutMarker()
        layoutLabels()
    }
    
    private func layoutBars() {
        let totalWidth = bounds.width
        let yellowMax: CGFloat = 69
        let greenMax: CGFloat = 99
        
        let yellowWidth = totalWidth * ((yellowMax - rangeMin) / (rangeMax - rangeMin))
        let greenWidth = totalWidth * ((greenMax - yellowMax) / (rangeMax - rangeMin))
        let redWidth = totalWidth - yellowWidth - greenWidth
        
        yellowBar.frame = CGRect(x: 0, y: 0, width: yellowWidth, height: barHeight)
        yellowBar.round(corners: [.topLeft, .bottomLeft], radius: barHeight / 2)
        greenBar.frame = CGRect(x: yellowWidth, y: 0, width: greenWidth, height: barHeight)
        redBar.frame = CGRect(x: yellowWidth + greenWidth, y: 0, width: redWidth, height: barHeight)
        redBar.round(corners: [.topRight, .bottomRight], radius: barHeight / 2)
    }
    
    private func layoutMarker() {
        let totalWidth = bounds.width
        let progressRatio = (bpm - rangeMin) / (rangeMax - rangeMin)
        let markerX = min(max(progressRatio, 0), 1) * totalWidth - markerWidth / 2
        marker.frame = CGRect(x: markerX, y: -4, width: markerWidth, height: barHeight + 8)
    }
    
    private func layoutLabels() {
        let totalWidth = bounds.width
        let labelY = barHeight + labelTopPadding
        
        let percent30: CGFloat = 0.0
        let percent69: CGFloat = (69 - rangeMin) / (rangeMax - rangeMin)
        let percent99: CGFloat = (99 - rangeMin) / (rangeMax - rangeMin)
        let percent130: CGFloat = 1.0
        
        let labels = [(label30, percent30), (label69, percent69), (label99, percent99), (label130, percent130)]
        
        for (label, percent) in labels {
            label.sizeToFit()
            let x = percent * totalWidth - label.frame.width / 2
            label.frame = CGRect(x: x,
                                 y: labelY,
                                 width: label.frame.width,
                                 height: label.frame.height)
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: barHeight + labelTopPadding + 16)
    }
}
