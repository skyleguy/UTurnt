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

//All of these methods are needed to be able to use [] notation on a String. Like str[3] gets the fourth character
extension String {
    subscript(i: Int) -> String {
        guard i >= 0 && i < characters.count else { return "" }
        return String(self[index(startIndex, offsetBy: i)])
    }
    subscript(range: Range<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) ?? endIndex))
    }
    subscript(range: ClosedRange<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound + 1, limitedBy: endIndex) ?? endIndex))
    }
}

class SecondController: UIViewController, CLLocationManagerDelegate
{
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var alreadyAdded = false
    var polyCount: Int = 0
    let locationManager = CLLocationManager()
    var currLocation: CLLocationCoordinate2D!
    var keyy = "AIzaSyBqm3VZ-er33Z6Pp6FI0d9KtKIBLpxcNjs"
    var numMinutes: Int!
    var switchPositioner: Bool!
    var drivingMethod: Any!
    var didFindMyLocation = false
    var routeButton = UIButton()
    var path = GMSMutablePath()
    var favButton = UIButton()
    var blah = GMSPolyline()
    var drivingMethoder : String!
    var allPoly : [GMSPolyline] = []
    var mapPolylines = UIButton()
    var deleteButton = UIButton()
    var navButton = UIButton()
    var thePath = GMSPolyline()
    var endButton = UIButton()
    var addFavLine = GMSPolyline()
    var addFavPath = GMSMutablePath()
    var clearButton = UIButton()
    var sum: Int = 0
    var monitor: Int = 0
    var fPath = GMSMutablePath()
    var sPath = GMSMutablePath()
    var tPath = GMSMutablePath()
    var finalPath = GMSMutablePath()
    var fPoly = GMSPolyline()
    var sPoly = GMSPolyline()
    var tPoly = GMSPolyline()
    var finalPoly = GMSPolyline()
    var endPoint = GMSMarker()
    var dFav = UIButton()
    var currPlace : CLLocationCoordinate2D!

    //1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blah = GMSCameraPosition.camera(withLatitude: 39.8282, longitude: -98.5795, zoom: 25.0)
        mapView.camera = blah
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        currLocation = mapView.myLocation?.coordinate
        
        routeButton = UIButton(type: .system)
        routeButton.frame = CGRect(x: 5, y: 40, width: 100, height: 40)
        routeButton.backgroundColor = UIColor.clear
        routeButton.layer.cornerRadius = 5
        routeButton.layer.borderWidth = 1
        routeButton.layer.borderColor = UIColor.blue.cgColor
        routeButton.setTitle("Route", for: UIControlState.normal)
        routeButton.addTarget(self, action: #selector(SecondController.buttonPressed), for: UIControlEvents.touchUpInside)
        self.view.addSubview(routeButton)
        
        favButton = UIButton(type: .system)
        favButton.frame = CGRect(x: 110, y: 40, width: 100, height: 40)
        favButton.backgroundColor = UIColor.clear
        favButton.layer.cornerRadius = 5
        favButton.layer.borderWidth = 1
        favButton.layer.borderColor = UIColor.blue.cgColor
        favButton.setTitle("Add", for: UIControlState.normal)
        favButton.addTarget(self, action: #selector(SecondController.addPoly), for: UIControlEvents.touchUpInside)
        self.view.addSubview(favButton)
        
        clearButton = UIButton(type: .system)
        clearButton.frame = CGRect(x: 110, y: 85, width: 100, height: 40)
        clearButton.backgroundColor = UIColor.clear
        clearButton.layer.cornerRadius = 5
        clearButton.layer.borderWidth = 1
        clearButton.layer.borderColor = UIColor.blue.cgColor
        clearButton.setTitle("Clear", for: UIControlState.normal)
        clearButton.addTarget(self, action: #selector(SecondController.clearLines), for: UIControlEvents.touchUpInside)
        self.view.addSubview(clearButton)
        
        mapPolylines = UIButton(type: .system)
        mapPolylines.frame = CGRect(x: 215, y: 40, width: 100, height: 40)
        mapPolylines.backgroundColor = UIColor.clear
        mapPolylines.layer.cornerRadius = 5
        mapPolylines.layer.borderWidth = 1
        mapPolylines.layer.borderColor = UIColor.blue.cgColor
        mapPolylines.setTitle("Show", for: UIControlState.normal)
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
        
        navButton = UIButton(type: .system)
        navButton.frame = CGRect(x: 5, y: 575, width: 100, height: 40)
        navButton.backgroundColor = UIColor.clear
        navButton.layer.cornerRadius = 5
        navButton.layer.borderWidth = 1
        navButton.layer.borderColor = UIColor.blue.cgColor
        navButton.setTitle("Navigate", for: UIControlState.normal)
        navButton.addTarget(self, action: #selector(SecondController.navigate), for: UIControlEvents.touchUpInside)
        self.view.addSubview(navButton)
        
        endButton = UIButton(type: .system)
        endButton.frame = CGRect(x: 5, y: 575, width: 100, height: 40)
        endButton.backgroundColor = UIColor.clear
        endButton.layer.cornerRadius = 5
        endButton.layer.borderWidth = 1
        endButton.layer.borderColor = UIColor.blue.cgColor
        endButton.setTitle("End", for: UIControlState.normal)
        endButton.isEnabled = false
        endButton.alpha = 0
        endButton.addTarget(self, action: #selector(SecondController.endNavigate), for: UIControlEvents.touchUpInside)
        self.view.addSubview(endButton)
        locationManager.stopUpdatingLocation()
        
        dFav = UIButton(type: .system)
        dFav.frame = CGRect(x: 215, y: 85, width: 100, height: 40)
        dFav.backgroundColor = UIColor.clear
        dFav.layer.cornerRadius = 5
        dFav.layer.borderWidth = 1
        dFav.layer.borderColor = UIColor.blue.cgColor
        dFav.setTitle("Delete Fav", for: UIControlState.normal)
        dFav.isEnabled = true
        dFav.alpha = 1
        dFav.addTarget(self, action: #selector(SecondController.deleteFav), for: UIControlEvents.touchUpInside)
        self.view.addSubview(dFav)
    }

    //no idea when this is run
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //2
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if status == CLAuthorizationStatus.authorizedWhenInUse
        {
            mapView.isMyLocationEnabled = true
            mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
            currLocation = mapView.myLocation?.coordinate
            didFindMyLocation = true
        }
        //print("LOCATION MANAGER")
    }
 
    //3
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        
        let myLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
        if (didFindMyLocation == false)
        {
            mapView.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 15.0)
            mapView.settings.myLocationButton = true
            didFindMyLocation = true
            currLocation = mapView.myLocation?.coordinate
        }
        /*
        var cam = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 15.0)
        
        if (monitor == 1)
        {
            cam = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 25.0)
        }
        //mapView.animate(to: cam)
        
        //print("WEIRD OBSERVER METHOD")
 */
    }
    
    //4
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var cam = GMSCameraPosition.camera(withLatitude: 39.8282, longitude: -98.5795, zoom: 25.0)
        if (monitor == 1)
        {
            //print("Updating Location Now")
            if let location = locationManager.location?.coordinate
            {
                cam = GMSCameraPosition.camera(withTarget: location, zoom: 17.5)
            }
            mapView.animate(to: cam)
        }
        else
        {
            if let location = locationManager.location?.coordinate
            {
                cam = GMSCameraPosition.camera(withTarget: location, zoom: 15.0)
            }
            mapView.animate(to: cam)
        }
        currLocation = locationManager.location?.coordinate
       // print("UPDATING METHOD")
    }
    
    //
    func getDirectionFromGoogle(startCoordinate: CLLocationCoordinate2D, toLocation: CLLocationCoordinate2D) -> GMSMutablePath
    {
        let thePath = GMSMutablePath()
        var returnValue = 0
        var avoidances = ""
        if (!(switchPositioner!))
        {
            avoidances = "&avoid=highways"
        }
        var urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(startCoordinate.latitude),\(startCoordinate.longitude)&destination=\(toLocation.latitude),\(toLocation.longitude)&mode=\(drivingMethoder!)\(avoidances)&key=\(keyy)"
        print(urlString)
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let session = URLSession.shared
        let placesTask = session.dataTask(with: URL(string: urlString)!, completionHandler: {data, response, error in
            if error != nil
            {
            }
            if let directions = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
            {
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
                                                                thePath.add(coordinate)
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
                    returnValue = self.findTravelTime(theJson: directions)
                    print("returned: \(returnValue)")
                    self.sum = self.sum + returnValue
                    print("Sum \(self.sum)")
                }
            }
        })
        placesTask.resume()
        return thePath
    }
   
    func deleteFav()
    {
        if (allPoly.count > 0 && polyCount != 0)
        {
            allPoly[polyCount - 1].map = nil
            allPoly.remove(at: polyCount - 1)
            print("i removed the poly at index \(polyCount - 1)")
            if (polyCount - 1 == allPoly.count)
            {
                polyCount = polyCount - 1
                print("polyCount is now \(polyCount)")
            }
        }
        else if (allPoly.count > 0 && polyCount != allPoly.count + 1 && polyCount != 0)
        {
            allPoly[0].map = nil
            allPoly.remove(at: 0)
        }
        if (allPoly.count == 1)
        {
            allPoly[0].map = nil
            allPoly.remove(at: 0)
        }
    }
    
    //clears Fav polys from map!
    func clearLines()
    {
        for i in 0 ..< allPoly.count
        {
            allPoly[i].map = nil
        }
        endPoint.map = nil
        polyCount = 0
    }
    
    //add's most recently routed poly to favPolys
    func addPoly()
    {
        if (alreadyAdded == false)
        {
            addFavLine.strokeColor = generateRandomColor()
            allPoly.append(addFavLine)
            endPoint.map = nil
            alreadyAdded = true
        }
    }
    
    //maps all of the favorited lines, line by line, until all of them 
    func mapPolylinez()
    {
        if (polyCount == 0)
        {
            for i in 0 ..< allPoly.count
            {
                allPoly[i].map = nil
                //print("cleared all lines because we reset")
            }
        }
        for i in 0 ..< allPoly.count
        {
            if (polyCount == i && i != 0)
            {
                allPoly[i - 1].map = nil
                allPoly[i].map = mapView
                //print("mapped a new line and cleared the one behind me")
            }
            else if (polyCount == i && i == 0)
            {
                allPoly[i].map = mapView
                //print("mapped a new line because im the first")
            }
        }
        if (polyCount == allPoly.count)
        {
            //print("mapping all lines because we went over by one")
            for i in 0 ..< allPoly.count
            {
                allPoly[i].map = mapView
            }
            polyCount = -1
        }
        
        if (polyCount > allPoly.count)
        {
            polyCount = -1
        }
        polyCount = polyCount + 1
        print("poly count \(polyCount)")
        print("all poly count \(allPoly.count)")
    }
    
    //Empties all saved polys!
    func clearAll()
    {
        for i in 0 ..< allPoly.count
        {
            allPoly[i].map = nil
        }
        allPoly.removeAll()
        endPoint.map = nil
        polyCount = 0
    }
    //routes a random polyline
    func buttonPressed()
    {
        alreadyAdded = false
        getValues()
        endPoint.title = ""
        endPoint.map = nil
        endPoint = GMSMarker()
        self.sum = 0
        blah.map = nil
        currPlace = currLocation
        let decider = arc4random_uniform(3) + 1
        if (decider == 1)
        {
            //latitude increases, longitude goes down
            whichDirection(firstNum: 1, secondNum: -1, pathNum: 1)
            let secondDecider = arc4random_uniform(1) + 1
            print("second decider is: \(secondDecider)")
            if (secondDecider == 0)
            {
                //latitude increases, longitude increases
                whichDirection(firstNum: 1, secondNum: 1, pathNum: 2)
                print("Field Sum: \(sum)")
                //latitude decreases, longitude increases
                whichDirection(firstNum: -1, secondNum: 1, pathNum: 3)
                whichDirection(firstNum: -1, secondNum: -1, pathNum: 4)
            }
            else
            {
                //latitude decreases, longitude decreases
                whichDirection(firstNum: -1, secondNum: -1, pathNum: 2)
                //latitude decreases, longitude increases
                whichDirection(firstNum: -1, secondNum: 1, pathNum: 3)
                whichDirection(firstNum: 1, secondNum: 1, pathNum: 4)
            }
        }
        else if (decider == 2)
        {
            //latitude increases, longitude increases
            whichDirection(firstNum: 1, secondNum: 1, pathNum: 1)
            let secondDecider = arc4random_uniform(1) + 1
            if (secondDecider == 0)
            {
                //latitude increases, longitude decreases
                whichDirection(firstNum: 1, secondNum: -1, pathNum: 2)
                print("Field Sum: \(sum)")
                //latitude decreases, longitude decreases
                whichDirection(firstNum: -1, secondNum: -1, pathNum: 3)
                whichDirection(firstNum: -1, secondNum: 1, pathNum: 4)
                
            }
            else
            {
                //latitude decreases, longitude increases
                whichDirection(firstNum: -1, secondNum: 1, pathNum: 2)
                //latitude decreases, longitude decreases
                whichDirection(firstNum: -1, secondNum: -1, pathNum: 3)
                whichDirection(firstNum: 1, secondNum: -1, pathNum: 4)
            }
        }
        else if (decider == 3)
        {
            //latitude decreases, longitude increases
            whichDirection(firstNum: -1, secondNum: 1, pathNum: 1)
            let secondDecider = arc4random_uniform(1) + 1
            if (secondDecider == 0)
            {
                //latitude increases, longitude increases
                whichDirection(firstNum: 1, secondNum: 1, pathNum: 2)
                print("Field Sum: \(sum)")
                //latitude increases, longitude decreases
                whichDirection(firstNum: 1, secondNum: -1, pathNum: 3)
                whichDirection(firstNum: -1, secondNum: -1, pathNum: 4)
            }
            else
            {
                //latitude decreases, longitude decreases
                whichDirection(firstNum: -1, secondNum: -1, pathNum: 2)
                //latitude increases, longitude decreases
                whichDirection(firstNum: 1, secondNum: -1, pathNum: 3)
                whichDirection(firstNum: 1, secondNum: 1, pathNum: 4)
            }
        }
        else if (decider == 4)
        {
            //latitude decreases, longitude decreases
            whichDirection(firstNum: -1, secondNum: -1, pathNum: 1)
            let secondDecider = arc4random_uniform(1) + 1
            if (secondDecider == 0)
            {
                //latitude decrease, longitude increases
                whichDirection(firstNum: -1, secondNum: 1, pathNum: 2)
                print("Field Sum: \(sum)")
                //latitude increases, longitude increases
                whichDirection(firstNum: 1, secondNum: 1, pathNum: 3)
                whichDirection(firstNum: -1, secondNum: 1, pathNum: 4)
            }
            else
            {
                //latitude increase, longitude decrease
                whichDirection(firstNum: 1, secondNum: -1, pathNum: 2)
                //latitude increase, longitude increase
                whichDirection(firstNum: 1, secondNum: 1, pathNum: 3)
                whichDirection(firstNum: -1, secondNum: 1, pathNum: 4)
            }
        }
        sleep(1)
        if (isCorrectMinutes())
        {
            print("printing map")
            fPoly = GMSPolyline(path: fPath)
            sPoly = GMSPolyline(path: sPath)
            tPoly = GMSPolyline(path: tPath)
            finalPoly = GMSPolyline(path:finalPath)
            addFavPath = fPath
            for index in 0 ..< sPath.count()
            {
                addFavPath.add(sPath.coordinate(at: index))
            }
            for index in 0 ..< tPath.count()
            {
                addFavPath.add(tPath.coordinate(at: index))
            }
            for index in 0 ..< finalPath.count()
            {
                addFavPath.add(finalPath.coordinate(at: index))
            }
            blah = GMSPolyline(path: addFavPath)
            addFavLine = blah
            addFavLine.strokeWidth = 10.0
            addFavLine.map = mapView
            fPath.removeAllCoordinates()
            sPath.removeAllCoordinates()
            tPath.removeAllCoordinates()
            finalPath.removeAllCoordinates()
            endPoint.position = CLLocationCoordinate2D(latitude: currLocation.latitude, longitude: currLocation.longitude)
            let numberMinutes = String(sum)
            endPoint.title = "\(numberMinutes) minutes"
            endPoint.map = mapView
        }
        else
        {
            print("retrying route generation")
            fPath.removeAllCoordinates()
            sPath.removeAllCoordinates()
            tPath.removeAllCoordinates()
            finalPath.removeAllCoordinates()
            self.buttonPressed()
        }
        
    }
    
    func generateRandom() -> Double
    {
        if (drivingMethoder == "driving")
        {
            if (numMinutes > 45 && numMinutes < 60)
            {
                return(Double(Double(arc4random()) / Double(UINT32_MAX))) / 15
            }
            else if (numMinutes < 45 && numMinutes > 30)
            {
                return(Double(Double(arc4random()) / Double(UINT32_MAX))) / 25
            }
            else if (numMinutes < 30 && numMinutes > 15)
            {
                return(Double(Double(arc4random()) / Double(UINT32_MAX))) / 50
            }
            else if (numMinutes < 15)
            {
                return(Double(Double(arc4random()) / Double(UINT32_MAX))) / 100
            }
            else
            {
                return (Double(Double(arc4random())))
            }
        }
        else if (drivingMethoder == "walking")
        {
            if (numMinutes > 45 && numMinutes < 60)
            {
                return(Double(Double(arc4random()) / Double(UINT32_MAX))) / 150
            }
            else if (numMinutes < 45 && numMinutes > 30)
            {
                return(Double(Double(arc4random()) / Double(UINT32_MAX))) / 250
            }
            else if (numMinutes < 30 && numMinutes > 15)
            {
                return(Double(Double(arc4random()) / Double(UINT32_MAX))) / 500
            }
            else if (numMinutes < 15)
            {
                return(Double(Double(arc4random()) / Double(UINT32_MAX))) / 1000
            }
            else
            {
                return (Double(Double(arc4random())))
            }
        }
        else if (drivingMethoder == "bicycling")
        {
            if (numMinutes > 45 && numMinutes < 60)
            {
                return(Double(Double(arc4random()) / Double(UINT32_MAX))) / 50
            }
            else if (numMinutes < 45 && numMinutes > 30)
            {
                return(Double(Double(arc4random()) / Double(UINT32_MAX))) / 100
            }
            else if (numMinutes < 30 && numMinutes > 15)
            {
                return(Double(Double(arc4random()) / Double(UINT32_MAX))) / 150
            }
            else if (numMinutes < 15)
            {
                return(Double(Double(arc4random()) / Double(UINT32_MAX))) / 210
            }
            else
            {
                return (Double(Double(arc4random())))
            }
        }
        return (Double(Double(arc4random())))
    }
    
    func findTravelTime(theJson : NSDictionary) -> Int
    {
        var realTime = ""
        var answer = 0
        if let routes = theJson["routes"] as? NSArray
        {
            if let legs = routes.value(forKey: "legs") as? NSArray
            {
                if let duration = legs.value(forKey: "duration") as? NSArray
                {
                    if let text = duration.value(forKey: "text") as? NSArray
                    {
                        let c = (text[0])
                        let cc = (c as AnyObject).object(at: 0) as! String
                        if (cc[1] == " ")
                        {
                            realTime = realTime + cc[0]
                        }
                        else if (cc[2] == " ")
                        {
                            realTime = realTime + cc[0] + cc[1]
                        }
                        let intNumber:Int? = Int(realTime)
                        answer = intNumber!
                    }
                }
            }
        }
        return answer
    }
    
    func navigate()
    {
        endPoint.map = nil
        monitor = 1
        let newCam = GMSCameraPosition.camera(withLatitude: currLocation.latitude, longitude: currLocation.longitude, zoom: 16.0)
        mapView.camera = newCam
        endButton.isEnabled = true
        endButton.alpha = 1
        clearButton.isEnabled = false
        clearButton.alpha = 0
        favButton.isEnabled = false
        favButton.alpha = 0
        dFav.isEnabled = false
        dFav.alpha = 0
        routeButton.isEnabled = false
        routeButton.alpha = 0
        deleteButton.isEnabled = false
        deleteButton.alpha = 0
        mapPolylines.isEnabled = false
        mapPolylines.alpha = 0
        navButton.alpha = 0
        navButton.isEnabled = false
        endButton.isEnabled = true
        endButton.alpha = 1
        locationManager.startUpdatingLocation()
    }
    
    func endNavigate()
    {
        monitor = 0
        endButton.isEnabled = false
        endButton.alpha = 0
        favButton.isEnabled = true
        favButton.alpha = 1
        dFav.isEnabled = true
        dFav.alpha = 1
        routeButton.isEnabled = true
        routeButton.alpha = 1
        deleteButton.isEnabled = true
        deleteButton.alpha = 1
        mapPolylines.isEnabled = true
        mapPolylines.alpha = 1
        navButton.alpha = 1
        navButton.isEnabled = true
        clearButton.isEnabled = true
        clearButton.alpha = 1
        let oldCam = GMSCameraPosition.camera(withLatitude: currLocation.latitude, longitude: currLocation.longitude, zoom: 15.0)
        mapView.camera = oldCam
        locationManager.stopUpdatingLocation()
    }
    
    func generateRandomColor() -> UIColor
    {
        let random1 : CGFloat = CGFloat(drand48())
        let random2 : CGFloat = CGFloat(drand48())
        let random3 : CGFloat = CGFloat(drand48())
        return UIColor(red: random1, green: random2, blue: random3, alpha: 1.0)
    }
    
    func isCorrectMinutes() -> Bool
    {
        if (sum >= numMinutes - 5 && sum <= numMinutes + 5)
        {
            print("Correct Length!")
            return true
        }
        print("incorrect length!")
        return false
    }
    
    func getValues()
    {
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
    }
    
    func whichDirection(firstNum: Int, secondNum: Int, pathNum: Int)
    {
        let randomNum = generateRandom()
        let randomNum2 = generateRandom()
        var newLat : Double
        var newLong : Double
        
        if (firstNum < 0 && secondNum < 0)
        {
            newLat = currLocation.latitude - randomNum
            newLong = currLocation.longitude - randomNum2
        }
        else if (firstNum < 0 && secondNum > 0)
        {
            newLat = currLocation.latitude - randomNum
            newLong = currLocation.longitude + randomNum2
        }
        else if (firstNum > 0 && secondNum < 0)
        {
            newLat = currLocation.latitude + randomNum
            newLong = currLocation.longitude - randomNum2
        }
        else
        {
            newLat = currLocation.latitude + randomNum
            newLong = currLocation.longitude + randomNum2
        }
        if (pathNum < 4)
        {
            let place = CLLocationCoordinate2DMake(newLat, newLong)
            let aPath = getDirectionFromGoogle(startCoordinate: currPlace!, toLocation: place)
            currPlace = place
            if (pathNum == 1)
            {
                fPath = aPath
            }
            else if (pathNum == 2)
            {
                sPath = aPath
            }
            else if (pathNum == 3)
            {
                tPath = aPath
            }
        }
        else if (pathNum == 4)
        {
            finalPath = getDirectionFromGoogle(startCoordinate: currPlace, toLocation: currLocation)
        }
    }
    
}
