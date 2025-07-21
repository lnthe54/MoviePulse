import UIKit

class WaveformChartView: UIView {

    var data: [CGFloat] = [] {
        didSet {
            updateChart()
        }
    }

    private let strokeLayer = CAShapeLayer()
    private let fillLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        strokeLayer.fillColor = UIColor.clear.cgColor
        strokeLayer.strokeColor = UIColor.pimaryColor.cgColor
        strokeLayer.lineWidth = 2

        fillLayer.fillColor = UIColor.black.cgColor

        gradientLayer.colors = [
            UIColor.pimaryColor.withAlphaComponent(0.4).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        layer.addSublayer(gradientLayer)
        gradientLayer.mask = fillLayer
        layer.addSublayer(strokeLayer)
    }

    private func updateChart() {
        guard data.count > 1 else {
            strokeLayer.path = nil
            fillLayer.path = nil
            return
        }

        let width = bounds.width
        let height = bounds.height
        let stepX = width / CGFloat(max(data.count - 1, 1))

        var points: [CGPoint] = []
        for i in 0..<data.count {
            let x = CGFloat(i) * stepX
            let normalized = max(min(data[i], 1.0), 0.0) // Clamp 0...1
            let y = height * (1 - normalized)
            points.append(CGPoint(x: x, y: y))
        }

        let path = UIBezierPath()
        path.move(to: points[0])

        for i in 1..<points.count {
            let prev = points[i - 1]
            let curr = points[i]
            let mid = CGPoint(x: (prev.x + curr.x) / 2, y: (prev.y + curr.y) / 2)
            path.addQuadCurve(to: mid, controlPoint: prev)
        }

        path.addQuadCurve(to: points.last!, controlPoint: points[points.count - 2])

        let fillPath = UIBezierPath()
        fillPath.append(path)
        fillPath.addLine(to: CGPoint(x: points.last!.x, y: height))
        fillPath.addLine(to: CGPoint(x: points.first!.x, y: height))
        fillPath.close()

        strokeLayer.path = path.cgPath
        fillLayer.path = fillPath.cgPath
        gradientLayer.frame = bounds
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateChart()
    }
}
