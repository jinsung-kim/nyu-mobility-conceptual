//
//  TrackingController.swift
//  NYU Mobility 2
//
//  Created by Jin Kim on 8/10/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreLocation
import CoreMotion

class TrackingController: UIViewController, AVCaptureFileOutputRecordingDelegate, CLLocationManagerDelegate {
    
    // The playback as the recording is being made
    @IBOutlet weak var camPreview: UIView!
    
    // Circle button that is pressed on
    @IBOutlet weak var cameraButton: UIView!
    
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    var saved: String = ""
    var json: String = ""
    
    // Movement tracking managers (copied from SpecialistTrackingController.swift)
    
    // Used to track pedometer when saving data
    private var steps: Int32 = 0
    private var prevSteps: Int32 = 0
    private var distance: Int32 = 0 // In meters
    private var prevDistance: Int32 = 0
    private var startTime: Date = Date()
    
    // GPS Location Services
    var coords: [CLLocationCoordinate2D] = []
    private let locationManager: CLLocationManager = CLLocationManager()
    private var locationArray: [String: [Double]] = ["long": [], "lat": []]
    
    // Used for creating the JSON
    var points: [Point] = []
    
    // Pedometer object - used to trace each step
    private let activityManager: CMMotionActivityManager = CMMotionActivityManager()
    private let pedometer: CMPedometer = CMPedometer()
    
    // Gyro Sensor
    private let motionManager: CMMotionManager = CMMotionManager()
    // Used to store all x, y, z values
//    private var gyroDict: [String: [Double]] = ["x": [], "y": [], "z": []]
    
    // Pace trackers
    private var currPace: Double = 0.0
    private var avgPace: Double = 0.0
    private var currCad: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Screen will not go to sleep with this line below
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Instructions Page Redirect setup
        getLocationPermission()
        
        if (setupSession()) {
            setupPreview()
            startSession()
        }
        setupButton()
    }
    
    /// Sets up the camera button used to start recording/stop recording
    func setupButton() {
        cameraButton.isUserInteractionEnabled = true
        let cameraButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(TrackingController.startCapture))
        cameraButton.addGestureRecognizer(cameraButtonRecognizer)
        cameraButton.backgroundColor = UIColor.white // button is white when initialized
        cameraButton.layer.cornerRadius = 30 // button round
        cameraButton.layer.masksToBounds = true
        
        camPreview.addSubview(cameraButton)
    }
    
    /// Sets up the camera view (which will start recording)
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        camPreview.layer.addSublayer(previewLayer)
    }

    /// Sets the quality of the video and adds camera as input
    func setupSession() -> Bool {
        captureSession.sessionPreset = AVCaptureSession.Preset.medium // Change this enum to higher/lower quality
        let camera = AVCaptureDevice.default(for: AVMediaType.video)!
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        if (captureSession.canAddOutput(movieOutput)) {
            captureSession.addOutput(movieOutput)
        }
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {}
    
    /// Starts recording session
    func startSession() {
        if (!captureSession.isRunning) {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    /// Stops recording session
    func stopSession() {
        if (captureSession.isRunning) {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    /// Only allows portrait mode
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        return AVCaptureVideoOrientation.portrait
    }
    
    @objc func startCapture() {
        startRecording()
    }
    
    /// Gets the directory that the video is stored in
    func getPathDirectory() -> URL {
        // Searches a FileManager for paths and returns the first one
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentDirectory = paths[0]
//        return documentDirectory
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }

    func generateURL() -> URL? {
        saved = safeTagGenerator()
        let path = getPathDirectory().appendingPathComponent(saved + ".mp4")
        return path
    }
    
    /// Used to include the file name, since we want to avoid using . within the file name
    func getSafeEmail() -> String{
        let email: String = UserDefaults.standard.string(forKey: "email")!
        return email.replacingOccurrences(of: "@", with: "-")
                    .replacingOccurrences(of: ".", with: "-")
    }
    
    /**
        Generates the tag for the video and matching JSON file
        Using the format: yyyy-MM-dd-hh-mm-ss
        Ex: 2020-09-04-12-23-43-jinkim-nyu-edu -> Used in generate URL for .mp4 and .json
     */
    func safeTagGenerator() -> String {
        var res: String = ""
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        res = df.string(from: startTime)
        // Safe value
        let email: String = getSafeEmail()
        res = res + "-" + email
        return res
    }
    
    /// Used to transfer data over to the share video
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Currently not being used (Playback)
        if (segue.identifier == "ShareVideo") {
            let vc = segue.destination as! PlaybackController
            vc.videoURL = outputURL
            vc.saved = saved
            vc.json = json
        } else if (segue.identifier == "ShareVideoTest") { // Sends to the screen to share
            let vc = segue.destination as! ShareVideoController
            vc.videoURL = outputURL
            vc.saved = saved
            vc.json = json
        }
    }
    
    func startRecording() {
        
        if (movieOutput.isRecording == false) {
            cameraButton.backgroundColor = UIColor.red
            
            startTracking()
            startTime = Date()
            
            let connection = movieOutput.connection(with: AVMediaType.video)
            
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
            }
            
            outputURL = generateURL()
            movieOutput.startRecording(to: outputURL!, recordingDelegate: self)
            
        } else {
            stopRecording()
        }
    }
    
    func stopRecording() {
        if (movieOutput.isRecording == true) {
            cameraButton.backgroundColor = UIColor.white
            movieOutput.stopRecording()
            stopTracking()
            clearData()
        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!,
                 didStartRecordingToOutputFileAt fileURL: URL!,
                 fromConnections connections: [Any]!) {}
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            performSegue(withIdentifier: "ShareVideoTest", sender: outputURL!)
        }
    }
    
    // GPS Location Services
    
    func getLocationPermission() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    // Continuously gets the location of the user
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for _ in locations { // _ -> currentLocation
            if let location: CLLocation = locationManager.location {
                // Coordinate object
                let coordinate: CLLocationCoordinate2D = location.coordinate
                coords.append(coordinate)
                // ... proceed with the location and coordinates
                if (locationArray["lat"] == nil) {
                    locationArray["lat"] = [coordinate.latitude]
                    locationArray["long"] = [coordinate.longitude]
                } else {
                    locationArray["lat"]!.append(coordinate.latitude)
                    locationArray["long"]!.append(coordinate.longitude)
                }
            }
            // Looks like this when debugged (city bike ride):
            // (Function): <+37.33144466,-122.03075535> +/- 30.00m
            // (speed 6.01 mps / course 180.98) @ 3/13/20, 8:55:48 PM Pacific Daylight Time
        }
    }
    
    // Pedometer Tracking
    
    /**
        Starts the gyroscope tracking, GPS location tracking, and pedometer object
        Assumes that location permissions and motion permissions have already been granted
        Changes the color of the UIView to green (indicating that it is in go mode)
        - Parameters:
            - fileName: The name of the file that should be played
     */
    func startTracking() {
        locationManager.startUpdatingLocation()
        startUpdating()
        saveData(currTime: Date(), significant: true)
    }
    
    /**
        Stops tracking the gyroscope, GPS location, and pedometer object
        Assumes that the previously stated managers are running
     */
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        stopUpdating()
        saveData(currTime: Date(), significant: true)
        json = generateJSON()
    }
    
    func stopUpdating() { pedometer.stopUpdates() }
    
    // Pedometer Functions
    
    func startUpdating() {
        if CMMotionActivityManager.isActivityAvailable() {
            startTrackingActivityType()
        }

        if CMPedometer.isStepCountingAvailable() {
            startCountingSteps()
        }
    }
    
    func startTrackingActivityType() {
        activityManager.startActivityUpdates(to: OperationQueue.main) {
            [weak self] (activity: CMMotionActivity?) in
            self?.steps = 0
            self?.distance = 0
            self?.prevSteps = 0
            self?.prevDistance = 0
        }
    }
    
    func startCountingSteps() {
        pedometer.startUpdates(from: Date()) {
          [weak self] pedometerData, error in
          guard let pedometerData = pedometerData, error == nil else { return }

            // Runs concurrently
            DispatchQueue.main.async {
                self?.saveData(currTime: Date(), significant: false)
                self?.distance = Int32(truncating: pedometerData.distance ?? 0)
                self?.steps = Int32(truncating: pedometerData.numberOfSteps)
                self?.avgPace = Double(truncating: pedometerData.averageActivePace ?? 0)
                self?.currPace = Double(truncating: pedometerData.currentPace ?? 0)
                self?.currCad = Double(truncating: pedometerData.currentCadence ?? 0)
            }
        }
    }
    
    func dateToString(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    /**
        Saves the given data into the stack, and clears out the gyroscope data to start taking values again
        - Parameters:
            - currTime: Date in which the data has been tracked
            - significant: Whether the point must be included or not (depreciated for testing model)
     */
    func saveData(currTime: Date, significant: Bool) {
        // JSON array implementation (See Point.swift for model)
        var temp: Int32 = steps // Ex: 5 steps in the last session
        steps = steps - prevSteps
        prevSteps = temp
        
        temp = distance
        distance = distance - prevDistance
        prevDistance = temp
        
        // These cases happen when the session has ended
        // Essentially, the last session value points will include the total for the session
        if (distance < 0) {
            distance *= -1
        }
        
        if (steps < 0) {
            steps *= -1
        }
        
        points.append(Point(dateToString(), steps,
                            distance, avgPace, currPace,
                            currCad, locationArray))
        locationArray.removeAll()
        locationArray = ["long": [], "lat": []]
    }
    
    // Generate JSON in String form
    func generateJSON() -> String {
        let dicArray = points.map { $0.convertToDictionary() }
        if let data = try? JSONSerialization.data(withJSONObject: dicArray, options: .prettyPrinted) {
            let str = String(bytes: data, encoding: .utf8)
            return str!
        }
        return "There was an error generating the JSON file" // shouldn't ever happen
    }

    func clearData() {
        points.removeAll()
    }
}
