//
//  ClearCache.swift
//  video-stream
//
//  Created by Rplay on 16/05/16.
//  Copyright © 2016 rplay. All rights reserved.
//

import Foundation

class ClearCache {
    init() {
        if let cachesDirectoryUrl = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).last  {
            var error: NSError?
            do {
                let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(cachesDirectoryUrl.path!)
                for cacheFile in contents {
                    let fileToDelete = cachesDirectoryUrl.URLByAppendingPathComponent(cacheFile as! String)
                    var removeError: NSError
                    do {
                        try NSFileManager.defaultManager().removeItemAtURL(fileToDelete)
                    } catch _ {
                    }
                }
            } catch var error1 as NSError {
                error = error1
            }
        }
        
        if let documentDirectoryUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last  {
            var error: NSError?
            do {
                let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentDirectoryUrl.path!)
                for documentFile in contents {
                    let fileToDelete = documentDirectoryUrl.URLByAppendingPathComponent(documentFile as! String)
                    var removeError: NSError
                    do {
                        try NSFileManager.defaultManager().removeItemAtURL(fileToDelete)
                    } catch _ {
                    }
                }
            } catch var error1 as NSError {
                error = error1
            }
        }
    }
}