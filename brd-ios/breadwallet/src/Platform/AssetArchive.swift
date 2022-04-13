//
//  AssetArchive.swift
//  breadwallet
//
//  Created by Ehsan Rezaie on 2019-02-13.
//  Copyright © 2019 Breadwinner AG. All rights reserved.
//

import Foundation

open class AssetArchive {
    let name: String
    private let fileManager: FileManager
    private let archiveUrl: URL
    private let archivePath: String
    private let extractedPath: String
    let extractedUrl: URL
    private unowned let apiClient: BRAPIClient
    
    private var archiveExists: Bool {
        return fileManager.fileExists(atPath: archivePath)
    }
    
    private var extractedDirExists: Bool {
        return fileManager.fileExists(atPath: extractedPath)
    }
    
    var version: String? {
        guard let archiveContents = try? Data(contentsOf: archiveUrl) else {
            return nil
        }
        return archiveContents.sha256.hexString
    }
    
    init?(name: String, apiClient: BRAPIClient) {
        self.name = name
        self.apiClient = apiClient
        self.fileManager = FileManager.default
        let bundleDirUrl = apiClient.bundleDirUrl
        archiveUrl = bundleDirUrl.appendingPathComponent("\(name).tar")
        extractedUrl = bundleDirUrl.appendingPathComponent("\(name)-extracted", isDirectory: true)
        archivePath = archiveUrl.path
        extractedPath = extractedUrl.path
    }
    
    func update(completionHandler: @escaping (_ error: Error?) -> Void) {
        do {
            try ensureExtractedPath()
            //If directory creation failed due to file existing
        } catch let error as NSError where error.code == 512 && error.domain == NSCocoaErrorDomain {
            do {
                try fileManager.removeItem(at: apiClient.bundleDirUrl)
                try fileManager.createDirectory(at: extractedUrl, withIntermediateDirectories: true, attributes: nil)
            } catch let e {
                return completionHandler(e)
            }
        } catch let e {
            return completionHandler(e)
        }
        
        copyBundledArchive()
        
        apiClient.getAssetVersions(name) { versions, err in
            DispatchQueue.global(qos: .utility).async {
                if let err = err {
                    print("[AssetArchive] could not get asset versions. error: \(err)")
                    
                    return completionHandler(err)
                }
                
                guard let versions = versions, let version = self.version else {
                    return completionHandler(BRAPIClientError.unknownError)
                }
                
                if versions.firstIndex(of: version) == versions.count - 1 {
                    print("[AssetArchive] already at most recent version of bundle \(self.name)")
                    
                    self.extract { error in
                        completionHandler(error)
                    }
                } else {
                    self.downloadCompleteArchive(completionHandler: completionHandler)
                }
            }
        }
    }
    
    fileprivate func extract(completionHandler: @escaping (_ error: Error?) -> Void) {
        do {
            try BRTar.createFilesAndDirectoriesAtPath(extractedPath, withTarPath: archivePath)
            
            completionHandler(nil)
        } catch let error {
            completionHandler(error)
            
            print("[AssetArchive] error extracting bundle: \(error)")
        }
    }
    
    fileprivate func downloadCompleteArchive(completionHandler: @escaping (_ error: Error?) -> Void) {
        apiClient.downloadAssetArchive(name) { (data, err) in
            DispatchQueue.global(qos: .utility).async {
                if let err = err {
                    print("[AssetArchive] error downloading complete archive \(self.name) error=\(err)")
                    
                    return completionHandler(err)
                }
                guard let data = data else {
                    return completionHandler(BRAPIClientError.unknownError)
                }
                do {
                    try data.write(to: self.archiveUrl, options: .atomic)
                    
                    self.extract { error in
                        return completionHandler(error)
                    }
                } catch let e {
                    print("[AssetArchive] error extracting complete archive \(self.name) error=\(e)")
                    
                    return completionHandler(e)
                }
            }
        }
    }
    
    fileprivate func ensureExtractedPath() throws {
        if !extractedDirExists {
            try fileManager.createDirectory(atPath: extractedPath,
                                            withIntermediateDirectories: true,
                                            attributes: nil
            )
        }
    }
    
    fileprivate func copyBundledArchive() {
        if let bundledArchiveUrl = Bundle.main.url(forResource: name, withExtension: "tar") {
            do {
                try fileManager.copyItem(at: bundledArchiveUrl, to: archiveUrl)
                
                print("[AssetArchive] used bundled archive for \(name)")
            } catch let error {
                print("[AssetArchive] unable to copy bundled archive `\(name)` \(bundledArchiveUrl) -> \(archiveUrl): \(error)")
            }
        }
    }
}
