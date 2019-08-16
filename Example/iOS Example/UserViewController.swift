//
//  UserViewController.swift
//  iOS Example
//
//  Created by Xuan Jie Chew on 09/08/2019.
//  Copyright (c) 2019 Parousya. All rights reserved.
//

import UIKit
import ParousyaSAASSDK

class UserViewController: UIViewController {

	@IBOutlet var zoneLabel : UILabel!
	@IBOutlet var versionLabel : UILabel!
	@IBOutlet var personIdLabel : UILabel!
	@IBOutlet var beaconLabel : UILabel!
	@IBOutlet var eventsTextView : UITextView!
	
	@IBOutlet var elapsedTimeLabel : UILabel!
	@IBOutlet var startTimeLabel : UILabel!
	@IBOutlet var startLocationLabel : UILabel!
	@IBOutlet var endTimeLabel : UILabel!
	@IBOutlet var endLocationLabel : UILabel!
	@IBOutlet var endAllSessionsButton : UIButton!
	
	private var activeSessions = [PRSSesssionStartedModel]()
	private var elapsedTimeTimer: Timer?
	
	lazy private var dateComponentFormatter : DateComponentsFormatter = {
		let dateComponentFormatter = DateComponentsFormatter()
		dateComponentFormatter.zeroFormattingBehavior = DateComponentsFormatter.ZeroFormattingBehavior.pad
		dateComponentFormatter.allowedUnits = [NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second]
		return dateComponentFormatter
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		let userDefaults = UserDefaults.standard
		
		if let value = userDefaults.object(forKey: ParousyaSAASSampleClientConstants.userTypeKey) as? Int,
			let userType = PRSPersonType(rawValue: value),
			let userId = userDefaults.object(forKey: ParousyaSAASSampleClientConstants.userIdKey) as? String {
			switch userType {
			case .host:
				self.title = "HOST"
				self.personIdLabel.text = "Host ID: \(userId)"
			case .customer:
				self.title = "CUSTOMER"
				self.personIdLabel.text = "Customer ID: \(userId)"
			}
		}
		
		if let zoneName = ParousyaSAASSDK.getZoneName() {
			self.zoneLabel.text = "Tag: \(zoneName)"
		}
		
		if let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
			let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
			self.versionLabel.text = "v\(versionNumber)(\(buildNumber))"
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(didChangeDetectedBeacons), name: Notification.Name.didChangeDetectedBeacons, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(zoneEvents), name: Notification.Name.didEnterBeaconTagRegion, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(zoneEvents), name: Notification.Name.didExitBeaconTagRegion, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(zoneEvents), name: Notification.Name.didPairBeacon, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(zoneEvents), name: Notification.Name.didUnpairBeacon, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(sessionStarted), name: Notification.Name.didStartSessionWithCustomer, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(sessionStarted), name: Notification.Name.didStartSessionWithHost, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(sessionEnded), name: Notification.Name.didEndSessionByHost, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(sessionEnded), name: Notification.Name.didEndSessionByCustomer, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(sessionEnded), name: Notification.Name.didEndSessionsByBeingOutOfRange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(sessionEnded), name: Notification.Name.didEndSessionManually, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(sessionEnded), name: Notification.Name.didEndAllSessionsManually, object: nil)
		
		self.navigationItem.setHidesBackButton(true, animated: false)
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self)
	}
	
	@IBAction func signOut(_ sender: UIButton) {
		let userDefaults = UserDefaults.standard
		userDefaults.removeObject(forKey: ParousyaSAASSampleClientConstants.userIdKey)
		userDefaults.removeObject(forKey: ParousyaSAASSampleClientConstants.userTypeKey)
		userDefaults.synchronize()
		
		ParousyaSAASSDK.stop(onSuccess: {
			self.elapsedTimeTimer?.invalidate()
			self.activeSessions.removeAll()
			self.navigationController?.popViewController(animated: true)
		}) { error in
			self.elapsedTimeTimer?.invalidate()
			self.activeSessions.removeAll()
			self.navigationController?.popViewController(animated: true)
		}
	}
	
	@IBAction func endSession(_ sender: UIButton) {
		ParousyaSAASSDK.endAllSessions()
	}
	
	@objc func didChangeDetectedBeacons(notification: Notification) {
		guard let beacons = notification.object as? [PRSBeaconModel] else {
			return
		}
		if beacons.count == 0 {
			self.beaconLabel.text = "Not in beacon range"
		}
		else {
			var beaconStringArray = [String]()
			for beacon in beacons {
				beaconStringArray.append("[\(beacon.major),\(beacon.minor)]")
			}
			self.beaconLabel.text = beaconStringArray.joined(separator: "\n")
		}
		
		self.eventsTextView.text = "BEACONS RANGED: \(beacons.count)\n\(self.eventsTextView.text ?? "")"
	}
	
	@objc func sessionStarted(notification: Notification) {
		guard let sessionStartedObject = notification.object as? PRSSesssionStartedModel else {
			return
		}
		
		self.activeSessions.append(sessionStartedObject)
		
		self.eventsTextView.text = "SESSION STARTED\n\(self.eventsTextView.text ?? "")"
		
		self.elapsedTimeLabel.isHidden = false
		self.startTimeLabel.text = "Start Time: \(DateFormatter.localizedString(from: sessionStartedObject.startTime, dateStyle: .short, timeStyle: .medium))"
		self.startTimeLabel.isHidden = false
		self.startLocationLabel.text = "Start Location: \(sessionStartedObject.locationDescription)"
		self.startLocationLabel.isHidden = false
		self.endTimeLabel.isHidden = true
		self.endLocationLabel.isHidden = true
		
		if notification.name == Notification.Name.didStartSessionWithCustomer {
			self.endAllSessionsButton.isHidden = false
		}
		
		if let elapsedTimeTimer = self.elapsedTimeTimer, elapsedTimeTimer.isValid {
			elapsedTimeTimer.invalidate()
		}
		self.elapsedTimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [unowned self] timer in
			self.elapsedTimeLabel.text = self.dateComponentFormatter.string(from: fabs(sessionStartedObject.startTime.timeIntervalSinceNow))
		})
		self.elapsedTimeTimer?.tolerance = 0.1
	}
	
	@objc func sessionEnded(notification: Notification) {
		var sessionEndedObject : PRSSesssionEndedModel
		if let sessionEndedObjects = notification.object as? [PRSSesssionEndedModel],
			let lastSessionEndedObject = sessionEndedObjects.last {
			sessionEndedObject = lastSessionEndedObject
			
			for sessionEndedObject in sessionEndedObjects {
				if let index = self.activeSessions.firstIndex(where: { activeSession -> Bool in
					activeSession.sessionId == sessionEndedObject.sessionId
				}) {
					self.activeSessions.remove(at: index)
				}
			}
		}
		else if let object = notification.object as? PRSSesssionEndedModel {
			sessionEndedObject = object
			
			if let index = self.activeSessions.firstIndex(where: { activeSession -> Bool in
				activeSession.sessionId == sessionEndedObject.sessionId
			}) {
				self.activeSessions.remove(at: index)
			}
		}
		else {
			return
		}
		
		switch notification.name {
		case Notification.Name.didEndSessionManually:
			self.eventsTextView.text = "SESSION ENDED MANUALLY\n\(self.eventsTextView.text ?? "")"
		case Notification.Name.didEndAllSessionsManually:
			self.eventsTextView.text = "ALL SESSIONS ENDED MANUALLY\n\(self.eventsTextView.text ?? "")"
		case Notification.Name.didEndSessionByHost:
			self.eventsTextView.text = "SESSION ENDED BY HOST\n\(self.eventsTextView.text ?? "")"
		case Notification.Name.didEndSessionsByBeingOutOfRange:
			self.eventsTextView.text = "SESSION ENDED DUE TO RANGE\n\(self.eventsTextView.text ?? "")"
		case Notification.Name.didEndSessionByCustomer:
			self.eventsTextView.text = "SESSION ENDED BY CUSTOMER\n\(self.eventsTextView.text ?? "")"
		default:
			break
		}
		
		guard let latestActiveSession = self.activeSessions.last else {
			self.elapsedTimeTimer?.invalidate()
			self.endAllSessionsButton.isHidden = true
			
			self.endTimeLabel.text = "End Time: \(DateFormatter.localizedString(from: sessionEndedObject.endTime, dateStyle: .short, timeStyle: .medium))"
			self.endTimeLabel.isHidden = false
			self.endLocationLabel.text = "End Location: \(sessionEndedObject.locationDescription)"
			self.endLocationLabel.isHidden = false
			
			return
		}
		
		// Update start location and time based on latest active session
		self.startTimeLabel.text = "Start Time: \(DateFormatter.localizedString(from: latestActiveSession.startTime, dateStyle: .short, timeStyle: .medium))"
		self.startLocationLabel.text = "Start Location: \(latestActiveSession.locationDescription)"
		
		self.elapsedTimeTimer?.invalidate()
		self.elapsedTimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [unowned self] timer in
			self.elapsedTimeLabel.text = self.dateComponentFormatter.string(from: fabs(latestActiveSession.startTime.timeIntervalSinceNow))
		})
		self.elapsedTimeTimer?.tolerance = 0.1
	}
	
	@objc func zoneEvents(notification: Notification) {
		switch notification.name {
		case Notification.Name.didEnterBeaconTagRegion:
			self.eventsTextView.text = "ZONE ENTRY\n\(self.eventsTextView.text ?? "")"
		case Notification.Name.didExitBeaconTagRegion:
			self.eventsTextView.text = "ZONE EXIT\n\(self.eventsTextView.text ?? "")"
		case Notification.Name.didPairBeacon:
			self.eventsTextView.text = "BEACON PAIRED\n\(self.eventsTextView.text ?? "")"
		case Notification.Name.didUnpairBeacon:
			self.eventsTextView.text = "BEACON UNPAIRED\n\(self.eventsTextView.text ?? "")"
		default:
			break
		}
	}
}
