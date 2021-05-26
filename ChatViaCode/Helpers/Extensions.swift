//
//  Extensions.swift
//  ChatViaCode
//
//  Created by MACsimus on 25.05.2021.
//


import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlStrind(urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImages = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImages
            return
        }
        
        // 1- create a url
        let url = URL(string: urlString)
        // 2- create a url session
        let session = URLSession(configuration: .default)
        // 3- give the session a task
        let task = session.dataTask(with: url!) { (data, responce, error) in
            if error != nil {
            print(error ?? "errorIn url session")
            return
            }
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    
                    self.image = downloadedImage
                }
                
                
            }
        }
        // 4- start the task
        task.resume()
    }
}
