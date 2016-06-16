//
//  AppDelegate.swift
//  Spoti2Music
//
//  Created by Issam Bendaas on 16/06/16.
//  Copyright © 2016 Issam Bendaas. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
		let csvDict = parseSpotifyPlaylist()[2]
		let title = csvDict["Track Name"]! as? String
		let artist = (csvDict["Artist Name"]! as? String)!
		let album = csvDict["Album Name"]! as? String
		
		print("title: \(title),  artist: \(artist),  album: \(album)")
		let trackName = title!.removeExcessiveSpaces
		let urlString = "https://itunes.apple.com/WebObjects/MZStore.woa/wa/search?clientApplication=MusicPlayer&term=" + trackName
		
		loadDataFromURL(NSURL(string: urlString)!) { (data, error) in
			if let _ = error { print(error); return}
			
			do {
				let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
				
				guard let results = jsonDict["storePlatformData"]!!["lockup"]!!["results"] as? NSDictionary! else { return }
				

				for song in results.allValues where song["kind"] as! String != "song" {
//					print((song["name"]!)!)
//					print((song["artistName"])!)
					
					guard let songname = song["name"]! as? String else { return }
					print("song: \(songname),  title: \(title!)")
					if let name = song["name"] as? String where name.lowercaseString == title!{
						
						print(song["name"]!)
						print(song["album"]!)
//						print(song["artistName"]!)
//						print(song["id"]!)
					}
					
				}
//				for r in results {
//					let song = r["kind"] as! String
//					print(r)
//				}
				
//				let song = result["kind"] as! String
//				if song == "song" {
//					print(result["name"])
//				}
				
			} catch {}
			
		}
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


	func parseSpotifyPlaylist() -> [AnyObject!] {
		var csvDict: [AnyObject!] = []
		let filePath = NSBundle.mainBundle().pathForResource("electronic_top_20",ofType:"csv")
		do {
			let csv = try CSV(url: NSURL(fileURLWithPath: filePath!))
			csv.enumerateAsDict { dict in
//				print(dict["Track Name"])
				csvDict.append(dict)
			}
			
		} catch {}
		
		return csvDict
	}
	
	func loadDataFromURL(url: NSURL, completion:(data:NSData?, error:NSError?) -> Void) {
		let session = NSURLSession.sharedSession()
		let request = NSMutableURLRequest(URL: url)
		request.addValue("143446-10,32 ab:rSwnYxS0 t:music2", forHTTPHeaderField: "X-Apple-Store-Front")
		request.addValue("7200", forHTTPHeaderField: "X-Apple-Tz")
		let loadDataTask = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
			if let _ = error { completion(data: nil, error: error)}
			else {completion(data: data, error: nil)}
		})
		
		loadDataTask.resume()
	}
}

extension String {
	var removeExcessiveSpaces: String {
		return componentsSeparatedByCharactersInSet(.whitespaceCharacterSet())
			.filter { !$0.isEmpty }
			.joinWithSeparator("")
	}
}