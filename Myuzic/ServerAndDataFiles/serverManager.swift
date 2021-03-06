//
//  serverManager.swift
//  myuzicBackground
//
//  Created by Arya Mirshafii on 12/18/17.
//  Copyright © 2017 Arya Mirshafii. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation
import SwiftyJSON
import MediaPlayer
extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: range.lowerBound)
        
        if(range.upperBound > endIndex.encodedOffset) {
            let idx2 = index(startIndex, offsetBy: endIndex.encodedOffset)
            return String(self[idx1..<idx2])
        }
        let idx2 = index(startIndex, offsetBy: range.upperBound)
        return String(self[idx1..<idx2])
        
    }
    var count: Int { return characters.count }
}
class serverManager: NSObject, CLLocationManagerDelegate{
    var locationManager = CLLocationManager()
    
    var stringURL:String = "http://143.215.114.209:3000/songs/"
    var predictionURL:String = "http://143.215.114.209:3000/aiPredictions/"
    
    var dataController = dataManager()
    private var shouldMakeMoreCalls = true;
    
    override init() {
        
    }
    
    func checkLocation() -> String{
        
        locationManager.delegate = self
        print("pre 12" )
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        print("pre 1" )
        let newLatitude:Int = Int(floor((locationManager.location?.coordinate.latitude)! * 1000))
        let newLongitude:Int = Int(floor((locationManager.location?.coordinate.longitude)! * 1000))
        print("Up to here")
        print(String(newLatitude))
        print(String(newLongitude)[1..<7])
        
        return String(newLatitude) + String(newLongitude)[1..<7]
        
        print("pre verify")
        if(verifyUrl()){
            /**
            locationManager.delegate = self
            print("pre 12" )
            
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            print("pre 1" )
            let newLatitude:Int = Int(floor((locationManager.location?.coordinate.latitude)! * 1000))
            let newLongitude:Int = Int(floor((locationManager.location?.coordinate.longitude)! * 1000))
            print("Up to here")
            print(String(newLatitude))
            print(String(newLongitude)[1..<7])
            
            return String(newLatitude) + String(newLongitude)[1..<7]*/
        }
        
        print("preturn" )
        return ""
        
    }
    
    
    func put(objectID:String, songtoAdd: String){
        if(verifyUrl()){
            let urlString = stringURL + objectID
            var previousSong:String = ""
            var previousLocation:String = ""
            Alamofire.request(urlString).responseJSON { response in
                debugPrint("All Response Info: \(response)")
                if let data = response.result.value {
                    let json = JSON(data)
                    previousSong = json.dictionaryObject!["songList"] as! String
                    previousLocation = json.dictionaryObject!["locationName"] as! String
                    var songArray = [String]()
                    songArray.append(previousSong)
                    songArray.append(songtoAdd)
                    
                    //let params = [ "songList": previousSong + " @" +  songtoAdd,"locationName": previousLocation] as [String : Any]
                    let params = [ "songList": songArray,"locationName": previousLocation] as [String : Any]
                    Alamofire.request(urlString, method: .put, parameters: params, encoding: JSONEncoding.default)
                        .responseJSON { response in
                            debugPrint(response)
                            print("it worked!!!")
                    }
                }
            }
        }
        
        
    }
    
    
    
    /**
    func postData(locationID:String, songName: String, bpm: String, artistName: String, albumName: String, numberOfPlays: String, genre:String){
        print("posting")
        //if(verifyUrl(urlString: stringURL)){
            let parameters = [ "locationName":  locationID ,"songName": songName, "bpm": bpm, "artistName":artistName,"albumName": albumName, "numberOfPlays": numberOfPlays, "genre" : genre] as [String : Any]
            
            
            //create the url with URL
            let url = URL(string: stringURL)! //change the url
            
            //create the session object
            let session = URLSession.shared
            
            //now create the URLRequest object using the url object
            var request = URLRequest(url: url)
            request.httpMethod = "POST" //set http method as POST
            
            do {
                print("request passed")
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            } catch let error {
                print(error.localizedDescription)
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            //create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                print("taks")
                
                guard error == nil else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        print(json)
                        print("DATA POSTED")
                    }
                } catch let error {
                    print("data not posted")
                    print(error.localizedDescription)
                }
            })
            task.resume()
      //  }
        
        
    }
 */
    
    
    func post2(genre: String, numberOfPlays: String,albumName: String, artistName: String, bpm: String, songName: String, locationName: String, numberOfSkips: String, duration: String,lastPlayed:String ){
        
        if (verifyUrl()) {
            
                let body: NSMutableDictionary? = [
                    "genre": "\(genre)",
                    "numberOfPlays": "\(numberOfPlays)",
                    "albumName": "\(albumName)",
                    "artistName": "\(artistName)",
                    "bpm": "\(bpm)",
                    "songName": "\(songName)",
                    "locationName": "\(locationName)",
                    "numberOfSkips": "\(numberOfSkips)",
                    "duration": "\(duration)",
                    "lastPlayed": "\(lastPlayed)"
                    
                ]
                
                let url = NSURL(string: self.stringURL as String)
                var request = URLRequest(url: url! as URL)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let data = try! JSONSerialization.data(withJSONObject: body!, options: JSONSerialization.WritingOptions.prettyPrinted)
                
                let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                if let json = json {
                    print(json)
                }
                request.httpBody = json!.data(using: String.Encoding.utf8.rawValue)
                let alamoRequest = Alamofire.request(request as URLRequestConvertible)
                alamoRequest.validate(statusCode: 200..<300)
                alamoRequest.responseString { response in
                    
                    switch response.result {
                    case .success:
                        print("Posted sucessfully")
                    case .failure( _):
                        
                        print("Cold not post data")
                    }
                }
            
            }
            
        
    }
    
    
    
    
    
    
    
    
    
    
    func saveToCoreData(){
        if(verifyUrl()){
            Alamofire.request(stringURL).responseJSON { response in
                
                if let json = response.result.value {
                    print(json)                        // get your json response
                }
                if let myData = response.data  {
                    
                    do {
                        
                        let myJason = try JSON(data: myData)
                        if(!myJason.isEmpty){
                            let myID = myJason[myJason.count - 1].dictionary!["_id"]?.string
                            
                            let locationName = myJason[myJason.count - 1]["locationName"].string
                            
                            self.dataController.saveData(objectID: String(describing: myID!) , locationID: String(locationName!))
                        }
                    } catch {
                        print("error has happened")
                    }
                }
            }
        }
        
       
    }
    
    private var songNames = [String]()
    func getPredictions() -> [String] {
        
        Alamofire.request(predictionURL).responseJSON { response in
            
        
            if let myData = response.data  {
                
                do {
                    
                    let myJason = try JSON(data: myData)
                    if(!myJason.isEmpty){
                        let mySongs:String! = myJason[myJason.count - 1].dictionary!["songList"]?.string
                        print("My Songs arreeeee")
                        
                        let songArr = mySongs.components(separatedBy: ",")
                        for someSong in songArr {
                            print(someSong)
                            self.songNames.append(someSong)
                        }
                        
                       
                        
                       
                    }
                } catch {
                    print("error has happened")
                }
            }
        }
        
        
        return songNames
    }
    
    
    
    
    
    func verifyUrl () -> Bool {
        
        
        var url: NSURL = NSURL(string: stringURL)!
        var request: NSURLRequest = NSURLRequest(url: url as URL)
        var response: URLResponse?
        
        let data =  try? NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response) as NSData?
        guard data != nil else {
            print("No connection to the server!")
            return false;
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print("error \(httpResponse.statusCode)")
        }
        print("Connected to server!")
        return true;
    }
}



