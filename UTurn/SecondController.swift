//
//  SecondController.swift
//  UTurn
//
//  Created by Stephen Kyle Lobsinger on 11/10/16.
//  Copyright © 2016 Stephen Kyle Lobsinger. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import GooglePlaces

class SecondController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    var currLocation: CLLocationCoordinate2D!
    var keyy = "AIzaSyBqm3VZ-er33Z6Pp6FI0d9KtKIBLpxcNjs"
    var numMinutes: Int!
    var switchPositioner: Bool!
    var drivingMethod: Any!
    var didFindMyLocation = false
    var routeButton = UIButton()
    var path = GMSMutablePath()
    var polyButton = UIButton()
    var blah = GMSPolyline()
    var drivingMethoder : String!
    var allPoly : [GMSPolyline] = []
    var mapPolylines = UIButton()
    var deleteButton = UIButton()
    var thePath = GMSPolyline()
    var theJson : NSDictionary!
    var sumTime = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blah = GMSCameraPosition.camera(withLatitude: 39.8282, longitude: -98.5795, zoom: 25.0)
        mapView.camera = blah
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.isMyLocationEnabled = true
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        currLocation = mapView.myLocation?.coordinate
        let defaults = UserDefaults.standard
        defaults.synchronize()
        numMinutes = (UserDefaults.standard.value(forKey: "numMinutes")!) as! Int
        let switchPosition = (UserDefaults.standard.value(forKey: "switchPosition")!)
        if (switchPosition as! Bool)
        {
            switchPositioner = true
        }
        else
        {
            switchPositioner = false
        }
        let drivingMethod = (UserDefaults.standard.value(forKey: "drivingMethod")!)
        drivingMethoder = drivingMethod as! String
        
        routeButton = UIButton(type: .system)
        routeButton.frame = CGRect(x: 5, y: 40, width: 100, height: 40)
        routeButton.backgroundColor = UIColor.clear
        routeButton.layer.cornerRadius = 5
        routeButton.layer.borderWidth = 1
        routeButton.layer.borderColor = UIColor.blue.cgColor
        routeButton.setTitle("Route", for: UIControlState.normal)
        routeButton.addTarget(self, action: #selector(SecondController.buttonPressed), for: UIControlEvents.touchUpInside)
        self.view.addSubview(routeButton)
        
        polyButton = UIButton(type: .system)
        polyButton.frame = CGRect(x: 110, y: 40, width: 100, height: 40)
        polyButton.backgroundColor = UIColor.clear
        polyButton.layer.cornerRadius = 5
        polyButton.layer.borderWidth = 1
        polyButton.layer.borderColor = UIColor.blue.cgColor
        polyButton.setTitle("Clear", for: UIControlState.normal)
        polyButton.addTarget(self, action: #selector(SecondController.polyPressed), for: UIControlEvents.touchUpInside)
        self.view.addSubview(polyButton)
        
        mapPolylines = UIButton(type: .system)
        mapPolylines.frame = CGRect(x: 215, y: 40, width: 100, height: 40)
        mapPolylines.backgroundColor = UIColor.clear
        mapPolylines.layer.cornerRadius = 5
        mapPolylines.layer.borderWidth = 1
        mapPolylines.layer.borderColor = UIColor.blue.cgColor
        mapPolylines.setTitle("Populate", for: UIControlState.normal)
        mapPolylines.addTarget(self, action: #selector(SecondController.mapPolylinez), for: UIControlEvents.touchUpInside)
        self.view.addSubview(mapPolylines)
        
        deleteButton = UIButton(type: .system)
        deleteButton.frame = CGRect(x: 5, y: 85, width: 100, height: 40)
        deleteButton.backgroundColor = UIColor.clear
        deleteButton.layer.cornerRadius = 5
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = UIColor.blue.cgColor
        deleteButton.setTitle("Delete", for: UIControlState.normal)
        deleteButton.addTarget(self, action: #selector(SecondController.clearAll), for: UIControlEvents.touchUpInside)
        self.view.addSubview(deleteButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if status == CLAuthorizationStatus.authorizedWhenInUse
        {
            mapView.isMyLocationEnabled = true
            currLocation = mapView.myLocation?.coordinate
        }
        print("LOCATION MANAGER")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if (didFindMyLocation == false)
        {
            let myLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
            mapView.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 15.0)
            mapView.settings.myLocationButton = true
            
            didFindMyLocation = true
            currLocation = mapView.myLocation?.coordinate
        }
    }
    
    func getDirectionFromGoogle(startCoordinate: CLLocationCoordinate2D, toLocation: CLLocationCoordinate2D) {
        var avoidances = ""
        if (!(switchPositioner!))
        {
            avoidances = "&avoid=highways"
        }
        var urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(startCoordinate.latitude),\(startCoordinate.longitude)&destination=\(toLocation.latitude),\(toLocation.longitude)&mode=\(drivingMethoder!)\(avoidances)&key=\(keyy)"
        //print(urlString)
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let session = URLSession.shared
        let placesTask = session.dataTask(with: URL(string: urlString)!, completionHandler: {data, response, error in
            if error != nil {
            }
            if let directions = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
            {
                //print("JSON result: \(directions)")
                self.theJson = directions
                if let routes = directions["routes"] as? NSArray
                {
                    if let legs = routes.value(forKey: "legs") as? NSArray
                    {
                        if let steps = legs.value(forKey: "steps") as? NSArray
                        {
                            if steps.count != 0
                            {
                                if let firstStep = steps.object(at: 0) as? NSArray
                                {
                                    if firstStep.count != 0
                                    {
                                        if let paths = firstStep.object(at: 0) as? NSArray
                                        {
                                            if paths.count > 0
                                            {
                                                for i in 0 ..< paths.count
                                                {
                                                    if let polyline = (paths[i] as AnyObject).value(forKey: "polyline") as? NSDictionary {
                                                        if let points = polyline.value(forKey: "points") as? String {
                                                            let gmsPath = GMSPath(fromEncodedPath: points)
                                                            for index in 0 ..< gmsPath!.count() {
                                                                let coordinate = gmsPath!.coordinate(at: index)
                                                                self.path.add(coordinate)
                                                                //print(coordinate)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
        //blah = GMSPolyline(path: path)
        //blah.strokeWidth = 10.0
        //addPoly(polyline: blah)
        //blah.map = mapView
        //findTravelTime()
        placesTask.resume()
    }
    
    func polyPressed()
    {
        for i in 0 ..< allPoly.count
        {
            allPoly[i].map = nil
        }
    }
    
    func addPoly(polyline: GMSPolyline)
    {
        allPoly.append(polyline)
    }
    
    func mapPolylinez()
    {
        for i in 0 ..< allPoly.count
        {
            allPoly[i].map = mapView
        }
    }
    
    func clearAll()
    {
        allPoly.removeAll()
    }
    
    func buttonPressed()
    {
        var currPlace = currLocation
        let decider = arc4random_uniform(3) + 1
        //print("first: \(decider)")
        //let decider = 1
        var randomNum = generateRandom()
        var randomNum2 = generateRandom()
        if (decider == 1)
        {
            //latitude increases, longitude goes down
            var newLat = currLocation.latitude + randomNum
            var newLong = currLocation.longitude - randomNum2
            var place = CLLocationCoordinate2DMake(newLat, newLong)
            getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
            
            currPlace = place
            let secondDecider = arc4random_uniform(1) + 1
            //let secondDecider = 0
            if (secondDecider == 0)
            {
                //latitude increases, longitude increases
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! + randomNum
                newLong = (currPlace?.longitude)! + randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                
                currPlace = place
                //latitude decreases, longitude increases
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! - randomNum
                newLong = (currPlace?.longitude)! + randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                
                currPlace = place
                getDirectionFromGoogle(startCoordinate: place, toLocation: currLocation)
                
            }
            else if decider == 1
            {
                //latitude decreases, longitude decreases
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! - randomNum
                newLong = (currPlace?.longitude)! - randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                currPlace = place
                //latitude decreases, longitude increases
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! - randomNum
                newLong = (currPlace?.longitude)! + randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                currPlace = place
                getDirectionFromGoogle(startCoordinate: place, toLocation: currLocation)
            }
        }
        else if decider == 2
        {
            //latitude increases, longitude increases
            var newLat = currLocation.latitude + randomNum
            var newLong = currLocation.longitude + randomNum2
            var place = CLLocationCoordinate2DMake(newLat, newLong)
            getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
            currPlace = place
            let secondDecider = arc4random_uniform(1) + 1
            if (secondDecider == 0)
            {
                //latitude increases, longitude decreases
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! + randomNum
                newLong = (currPlace?.longitude)! - randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                currPlace = place
                //latitude decreases, longitude decreases
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! - randomNum
                newLong = (currPlace?.longitude)! - randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                currPlace = place
                getDirectionFromGoogle(startCoordinate: place, toLocation: currLocation)
            }
            else
            {
                //latitude decreases, longitude increases
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! - randomNum
                newLong = (currPlace?.longitude)! + randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                currPlace = place
                //latitude decrease, longitude decrease
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! - randomNum
                newLong = (currPlace?.longitude)! - randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                currPlace = place
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
            }
        }
        else if decider == 3
        {
            //latitude decreases, longitude increases
            var newLat = currLocation.latitude - randomNum
            var newLong = currLocation.longitude + randomNum2
            var place = CLLocationCoordinate2DMake(newLat, newLong)
            getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
            currPlace = place
            let secondDecider = arc4random_uniform(1) + 1
            if (secondDecider == 0)
            {
                //latitude increases, longitude increases
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! + randomNum
                newLong = (currPlace?.longitude)! + randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                currPlace = place
                //latitude increases, longitude decreases
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! + randomNum
                newLong = (currPlace?.longitude)! - randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                currPlace = place
                getDirectionFromGoogle(startCoordinate: place, toLocation: currLocation)
            }
            else
            {
                //latitude decreases, longitude decreases
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! - randomNum
                newLong = (currPlace?.longitude)! - randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                currPlace = place
                //latitude increase, longitude decrease
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! + randomNum
                newLong = (currPlace?.longitude)! - randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                currPlace = place
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
            }
        }
        else if decider == 4
        {
            //latitude decrease, longitude decrease
            var newLat = currLocation.latitude - randomNum
            var newLong = currLocation.longitude - randomNum2
            var place = CLLocationCoordinate2DMake(newLat, newLong)
            getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
            currPlace = place
            let secondDecider = arc4random_uniform(1) + 1
            print("second: \(secondDecider)")
            if (secondDecider == 0)
            {
                //latitude increases, longitude decreases
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! + randomNum
                newLong = (currPlace?.longitude)! - randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                currPlace = place
                //latitude increases, longitude increases
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! - randomNum
                newLong = (currPlace?.longitude)! - randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                currPlace = place
                getDirectionFromGoogle(startCoordinate: place, toLocation: currLocation)
            }
            else
            {
                //latitude decreases, longitude increases
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! - randomNum
                newLong = (currPlace?.longitude)! + randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                currPlace = place
                //latitude increase, longitude increase
                randomNum = generateRandom()
                randomNum2 = generateRandom()
                newLat = (currPlace?.latitude)! + randomNum
                newLong = (currPlace?.longitude)! + randomNum2
                place = CLLocationCoordinate2DMake(newLat, newLong)
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
                currPlace = place
                getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
            }
        }
        blah = GMSPolyline(path: path)
        blah.strokeWidth = 10.0
        addPoly(polyline: blah)
        blah.map = mapView
        path.removeAllCoordinates()
    }
    
    func generateRandom() -> Double
    {
        return(Double(Double(arc4random()) / Double(UINT32_MAX))) / 10
    }
    
    func findTravelTime()
    {
        print("in travel time")
        print(theJson)
        if let routes = theJson["routes"] as? NSArray
        {
            print("1")
            if let legs = routes.value(forKey: "legs") as? NSArray
            {
                print("2")
                if let duration = legs.value(forKey: "duration") as? NSArray
                {
                    print("3")
                    if let text = duration.value(forKey: "text") as? NSArray
                    {
                        print("4")
                        for i in 0 ..< text.count
                        {
                            print("5")
                            print(text[i])
                        }
                    }
                }
            }
        }
    }
    
}
