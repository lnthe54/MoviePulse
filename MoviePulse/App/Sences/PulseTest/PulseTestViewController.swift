import UIKit
import Kingfisher
import AVFoundation

class PulseTestViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: PulseTestNavigator
    private var viewModel: PulseTestViewModel
    private var id: Int
    private var posterPath: String
    private var name: String
    private var bpmValue: Int = 0
    
    // Heart
    private var validFrameCounter = 0
    private var heartRateManager: HeartRateManager!
    private var hueFilter = Filter()
    private var pulseDetector = PulseDetector()
    private var inputs: [CGFloat] = []
    private var measurementStartedFlag = false
    private var timer: Timer?
    private var isOpenPulseResult: Bool = false
    
    init(
        navigator: PulseTestNavigator,
        viewModel: PulseTestViewModel,
        id: Int,
        posterPath: String,
        name: String
    ) {
        self.navigator = navigator
        self.viewModel = viewModel
        self.id = id
        self.posterPath = posterPath
        self.name = name
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var infoView: UIView!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var noteLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var previewView: UIView!
    @IBOutlet private weak var warningLabel: UILabel!
    @IBOutlet private weak var introView: UIView!
    @IBOutlet private weak var introLabel: UILabel!
    @IBOutlet private weak var resultView: UIView!
    @IBOutlet private weak var bpmValueLabel: UILabel!
    @IBOutlet private weak var bpmTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVideoCapture()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        previewView.backgroundColor = .clear
        previewView.setBorder(withColor: UIColor(hexString: "#E7D9FB") ?? .clear, width: 20)
        previewView.layer.cornerRadius = previewView.frame.height / 2
        previewView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
        
        DispatchQueue.main.async { [weak self] in
            self?.resetView()

            DispatchQueue.global(qos: .userInitiated).async {
                self?.initCaptureSession()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deinitCaptureSession()
    }

    override func actionBack() {
        navigator.popToViewController()
    }
    
    override func setupViews() {
        setupHeader(withType: .detail(title: "Pulse Test"))
        
        topConstraint.constant = Constants.HEIGHT_NAV
        
        infoView.backgroundColor = .white
        infoView.corner(8)
        
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.corner(8)
        posterImageView.kf.setImage(
            with: URL(string: Utils.getPosterPath(posterPath, size: .w342)),
            placeholder: UIImage(named: "ic_loading"),
            options: [.transition(ImageTransition.fade(1))]
        )
        
        noteLabel.text = "You're measuring your heartbeat with"
        noteLabel.textColor = UIColor(hexString: "#252934")
        noteLabel.font = .outfitFont(ofSize: 14)
        noteLabel.numberOfLines = 0
        noteLabel.textAlignment = .center
        
        nameLabel.text = name
        nameLabel.textColor = .blackColor
        nameLabel.font = .outfitFont(ofSize: 20, weight: .semiBold)
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        
        warningLabel.textColor = .blackColor
        warningLabel.font = .outfitFont(ofSize: 14, weight: .medium)
        warningLabel.numberOfLines = 0
        warningLabel.textAlignment = .center
        warningLabel.text = "Hold your index finger ☝️ still."
        
        introView.backgroundColor = UIColor(hexString: "#E7D9FB")
        introView.corner(8)
        
        introLabel.text = """
        • Place your fingertip gently over the rear camera and flash
        • Make sure your finger fully covers the lens and flash
        • Stay still and avoid moving
        """
        introLabel.textColor = .blackColor
        introLabel.font = .outfitFont(ofSize: 16, weight: .medium)
        introLabel.numberOfLines = 0
        
        resultView.isHidden = true
        resultView.backgroundColor = .pimaryColor
        resultView.setBorder(withColor: UIColor(hexString: "#E7D9FB") ?? .clear, width: 20)
        resultView.layer.cornerRadius = previewView.frame.height / 2
        resultView.layer.masksToBounds = true
        
        bpmValueLabel.font = .outfitFont(ofSize: 44, weight: .semiBold)
        bpmValueLabel.textColor = .white
        
        bpmTitleLabel.font = .outfitFont(ofSize: 24, weight: .medium)
        bpmTitleLabel.textColor = .white
        bpmTitleLabel.text = "BPM"
    }
}

extension PulseTestViewController {
    private func resetView() {
        resultView.isHidden = true
        warningLabel.isHidden = false
    }
    
    // MARK: - Frames Capture Methods
    private func initVideoCapture() {
        let specs = VideoSpec(fps: 30, size: CGSize(width: 300, height: 300))
        heartRateManager = HeartRateManager(cameraType: .back, preferredSpec: specs, previewContainer: previewView.layer)
        heartRateManager.imageBufferHandler = { [unowned self] (imageBuffer) in
            self.handle(buffer: imageBuffer)
        }
    }
    
    // MARK: - AVCaptureSession Helpers
    private func initCaptureSession() {
        heartRateManager.startCapture()
    }
    
    private func deinitCaptureSession() {
        timer?.invalidate()
        timer = nil
        heartRateManager.stopCapture()
        toggleTorch(status: false)
    }
    
    private func toggleTorch(status: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        device.toggleTorch(on: status)
    }
    
    private func startMeasurement() {
        DispatchQueue.main.async {
            self.toggleTorch(status: true)
            
            if self.timer == nil {
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    guard let self = self else { return }
                    
                    let average = self.pulseDetector.getAverage()
                    let pulse = 60.0 / average
                    
                    guard pulse != -60, pulse.isFinite else {
                        return
                    }
                    
                    showMeasurementResult(bpm: lroundf(pulse))
                }
            }
        }
    }
    
    private func showMeasurementResult(bpm: Int) {
        UIView.animate(withDuration: 0.2) {
            self.resultView.alpha = 1.0
        } completion: { _ in
            self.deinitCaptureSession()
            self.resultView.isHidden = false
            self.warningLabel.isHidden = true
            self.bpmValue = bpm
            self.bpmValueLabel.text = "\(bpm)"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.navigator.gotoPulseResultViewController(result: PulseResultInfo(
                    id: self.id,
                    date: Date(),
                    bpm: self.bpmValue,
                    name: self.name,
                    path: self.posterPath,
                    tension: 0)
                )
            })
        }
    }
}

//MARK: - Handle Image Buffer
extension PulseTestViewController {
    fileprivate func handle(buffer: CMSampleBuffer) {
        var redmean:CGFloat = 0.0;
        var greenmean:CGFloat = 0.0;
        var bluemean:CGFloat = 0.0;
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(buffer)
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)

        let extent = cameraImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        let averageFilter = CIFilter(name: "CIAreaAverage",
                              parameters: [kCIInputImageKey: cameraImage, kCIInputExtentKey: inputExtent])!
        let outputImage = averageFilter.outputImage!

        let ctx = CIContext(options:nil)
        let cgImage = ctx.createCGImage(outputImage, from:outputImage.extent)!
        
        let rawData:NSData = cgImage.dataProvider!.data!
        let pixels = rawData.bytes.assumingMemoryBound(to: UInt8.self)
        let bytes = UnsafeBufferPointer<UInt8>(start:pixels, count:rawData.length)
        var BGRA_index = 0
        for pixel in UnsafeBufferPointer(start: bytes.baseAddress, count: bytes.count) {
            switch BGRA_index {
            case 0:
                bluemean = CGFloat (pixel)
            case 1:
                greenmean = CGFloat (pixel)
            case 2:
                redmean = CGFloat (pixel)
            case 3:
                break
            default:
                break
            }
            BGRA_index += 1
        }
        
        let hsv = rgb2hsv((red: redmean, green: greenmean, blue: bluemean, alpha: 1.0))
        // Do a sanity check to see if a finger is placed over the camera
        if (hsv.1 > 0.5 && hsv.2 > 0.5) {
            DispatchQueue.main.async {
                self.warningLabel.text = "Measuring..."
                self.toggleTorch(status: true)
                if !self.measurementStartedFlag {
                    self.startMeasurement()
                    self.measurementStartedFlag = true
                }
            }
            validFrameCounter += 1
            inputs.append(hsv.0)
            // Filter the hue value - the filter is a simple BAND PASS FILTER that removes any DC component and any high frequency noise
            let filtered = hueFilter.processValue(value: Double(hsv.0))
            if validFrameCounter > 60 {
                self.pulseDetector.addNewValue(newVal: filtered, atTime: CACurrentMediaTime())
            }
        } else {
            validFrameCounter = 0
            measurementStartedFlag = false
            pulseDetector.reset()
            DispatchQueue.main.async {
                self.warningLabel.text = "Hold your index finger ☝️ still."
            }
        }
    }
}
