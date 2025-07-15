import UIKit

class BPMIndicatorView: UIView {

    private let bpmLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let markerView = UIView()
    private let scaleStack = UIStackView()
    private let descriptionLabel = UILabel()

    private let minBPM: Float = 30
    private let maxBPM: Float = 130

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
        updateBPM(89)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        bpmLabel.font = .boldSystemFont(ofSize: 32)
        bpmLabel.textAlignment = .center

        // Progress bar
        progressView.trackTintColor = .clear
        progressView.progressTintColor = .systemGreen
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false

        // Marker line
        markerView.backgroundColor = .black
        markerView.layer.cornerRadius = 1
        markerView.translatesAutoresizingMaskIntoConstraints = false

        // BPM scale labels
        scaleStack.axis = .horizontal
        scaleStack.distribution = .equalSpacing
        [30, 69, 99, 130].forEach {
            let label = UILabel()
            label.text = "\($0)"
            label.font = .systemFont(ofSize: 12)
            scaleStack.addArrangedSubview(label)
        }

        // Description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .darkGray

        [bpmLabel, progressView, markerView, scaleStack, descriptionLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            bpmLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            bpmLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            progressView.topAnchor.constraint(equalTo: bpmLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            progressView.heightAnchor.constraint(equalToConstant: 8),

            markerView.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            markerView.widthAnchor.constraint(equalToConstant: 2),
            markerView.heightAnchor.constraint(equalToConstant: 16),

            scaleStack.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            scaleStack.leadingAnchor.constraint(equalTo: progressView.leadingAnchor),
            scaleStack.trailingAnchor.constraint(equalTo: progressView.trailingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: scaleStack.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    func updateBPM(_ bpm: Int) {
        bpmLabel.text = "\(bpm) BPM"

        let progress = Float(bpm - Int(minBPM)) / (maxBPM - minBPM)
        progressView.setProgress(progress, animated: true)

        // Move marker view
        let barWidth = progressView.bounds.width
        let markerX = progressView.frame.origin.x + CGFloat(progress) * barWidth
        markerView.center.x = markerX

        // Change color based on zone
        switch bpm {
        case ..<69:
            progressView.progressTintColor = .systemYellow
            descriptionLabel.text = "Slightly low. Stay relaxed."
        case 69..<99:
            progressView.progressTintColor = .systemGreen
            descriptionLabel.text = "Normal range. Nothing to worry about!"
        default:
            progressView.progressTintColor = .systemRed
            descriptionLabel.text = "High. Consider slowing down."
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Recalculate marker position on layout
        let bpm = Int((progressView.progress * (maxBPM - minBPM)) + minBPM)
        updateBPM(bpm)
    }
}
