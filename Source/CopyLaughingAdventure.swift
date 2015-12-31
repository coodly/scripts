/*
* Copyright 2015 Coodly LLC
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation

enum Direction {
    case In
    case Out
}

extension String {
    func stringByAppendingPathComponent(component: String) -> String {
        var result = String(self)
        if let last = result.characters.last where last != "/" {
            result.appendContentsOf("/")
        }
        
        result.appendContentsOf(component)
        
        return result
    }
}

class Copy {
    var localFolder = "Thirdparty/LaughingAdventure"
    var remoteFolder = "../swift-laughing-adventure/Source/"
    var direction: Direction = .In
    
    init(arguments: [String]) {
        if arguments.count == 0 {
            return
        }
        
        if let _ = arguments.indexOf("out") {
            direction = .Out
        }
        
        if arguments.count == 3 {
            localFolder = arguments[1]
            remoteFolder = arguments[2]
        }
    }
    
    func copy() {
        if !inputValid() {
            print("Check input paths")
            return
        }
        
        let local = listLocalFiles()
        
        let sourcePath: String
        let destinationPath: String
        if direction == .In {
            sourcePath = remoteFolder
            destinationPath = localFolder
        } else {
            sourcePath = localFolder
            destinationPath = remoteFolder
        }
        
        copyFiles(local, sourcePath: sourcePath, destinationPath: destinationPath)
    }
    
    func copyFiles(files: [String], sourcePath: String, destinationPath: String) {
        let manager = NSFileManager.defaultManager()
        
        for file in files {
            let fromPath = sourcePath.stringByAppendingPathComponent(file)
            let toPath = destinationPath.stringByAppendingPathComponent(file)
            
            print("Copy \(fromPath) to \(toPath)")
            
            try! manager.removeItemAtPath(toPath)
            try! manager.copyItemAtPath(fromPath, toPath: toPath)
        }
    }
    
    func listLocalFiles() -> [String] {
        let files = listContentsOfFolder(localFolder)
        var cleaned = [String]()
        
        for file in files {
            cleaned.append(file.stringByReplacingOccurrencesOfString(localFolder, withString: ""))
        }
        
        return cleaned
    }
    
    func listContentsOfFolder(path: String) -> [String] {
        let manager = NSFileManager.defaultManager()
        let files = try! manager.contentsOfDirectoryAtPath(path)
        var returned = [String]()
        
        for file in files {
            let fullPath = path.stringByAppendingPathComponent(file)
            if pathIsDirectory(fullPath) {
                returned.appendContentsOf(listContentsOfFolder(fullPath))
            } else {
                returned.append(fullPath)
            }
        }
        
        return returned
    }
    
    func inputValid() -> Bool {
        var valid = true
        if !pathIsDirectory(localFolder) {
            print("\(localFolder) not valid")
            valid = false
        }

        if !pathIsDirectory(remoteFolder) {
            print("\(remoteFolder) not valid")
            valid = false
        }
        
        return valid
    }
    
    func pathIsDirectory(path: String) -> Bool {
        let manager = NSFileManager.defaultManager()
        var isDir : ObjCBool = false
        return manager.fileExistsAtPath(path, isDirectory: &isDir) && isDir
    }
}

print("Usage: swift CopyLaughingAdventure [direction: in | out] [local folder] [remote folder]")

var arguments = Array(Process.arguments)
arguments.removeAtIndex(0)
let copy = Copy(arguments: arguments)
copy.copy()