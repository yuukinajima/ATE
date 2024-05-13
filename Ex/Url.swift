//
//  Url.swift
//  Ex
//
//  Created by yuki najima on 2024/05/01.
//

import Foundation


extension URL {

    func whereFrom() -> URL? {
        guard let data = try? self.extendedAttribute(forName: "com.apple.metadata:kMDItemWhereFroms") else {
            return nil
        }
        guard let decodedData = try? PropertyListDecoder().decode([String].self, from: data) else {
            return nil
        }
        if decodedData.count < 0 {
            return nil
        }
        return URL(string: decodedData[0])
    }

    private func getResourceValue() -> (NSURL, AnyObject?) {
        let url = NSURL(fileURLWithPath: self.path)
        do{
            var resource : AnyObject?
            try url.getResourceValue(&resource, forKey: .tagNamesKey)
            return (url, resource)
        }catch{
            return (url, nil)
        }
    }


    func getTags() -> Set<String>?{
        let (_, resource) = self.getResourceValue()
        var tags : [String]
        if resource == nil {
            return nil
        }
        tags = resource as! [String]
        return Set(tags)
    }

    func addTags(_ addTagArray: String...) -> Set<String>? {
        let (url, resource) = self.getResourceValue()
        var tags : [String]
        if resource == nil {
            return nil
        }
        tags = resource as! [String]
        let currentTag = Set(tags)
        let newTags = currentTag.union(Set(addTagArray))

        do{
            try url.setResourceValue(Array(newTags), forKey: .tagNamesKey)
        }catch{
            return nil
        }
        return newTags
    }

    func setTags(_ tagArray: String...) -> Set<String>? {
        let (url, _) = self.getResourceValue()
        do {
            try url.setResourceValue(tagArray, forKey: .tagNamesKey)
        } catch {
            return nil
        }
        return nil
    }

    func removeTags(_ tagArray: String...) -> Set<String>? {
        let (url, resource) = self.getResourceValue()
        var tags : [String]
        if resource == nil {
            return nil
        }
        tags = resource as! [String]
        let currentTag = Set(tags)
        let newTags = currentTag.subtracting(Set(tagArray))

        do{
            try url.setResourceValue(Array(newTags), forKey: .tagNamesKey)
        }catch{
            return nil
        }
        return newTags
    }
    
    /// Get extended attribute.
    func extendedAttribute(forName name: String) throws -> Data  {

        let data = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> Data in

            // Determine attribute size:
            let length = getxattr(fileSystemPath, name, nil, 0, 0, 0)
            guard length >= 0 else { throw URL.posixError(errno) }

            // Create buffer with required size:
            var data = Data(count: length)

            // Retrieve attribute:
            let result =  data.withUnsafeMutableBytes { [count = data.count] in
                getxattr(fileSystemPath, name, $0.baseAddress, count, 0, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
            return data
        }
        return data
    }

    /// Set extended attribute.
    func setExtendedAttribute(data: Data, forName name: String) throws {

        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = data.withUnsafeBytes {
                setxattr(fileSystemPath, name, $0.baseAddress, data.count, 0, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
        }
    }

    /// Remove extended attribute.
    func removeExtendedAttribute(forName name: String) throws {

        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = removexattr(fileSystemPath, name, 0)
            guard result >= 0 else { throw URL.posixError(errno) }
        }
    }

    /// Get list of all extended attributes.
    func listExtendedAttributes() throws -> [String] {

        let list = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> [String] in
            let length = listxattr(fileSystemPath, nil, 0, 0)
            guard length >= 0 else { throw URL.posixError(errno) }

            // Create buffer with required size:
            var namebuf = Array<CChar>(repeating: 0, count: length)

            // Retrieve attribute list:
            let result = listxattr(fileSystemPath, &namebuf, namebuf.count, 0)
            guard result >= 0 else { throw URL.posixError(errno) }

            // Extract attribute names:
            let list = namebuf.split(separator: 0).compactMap {
                $0.withUnsafeBufferPointer {
                    $0.withMemoryRebound(to: UInt8.self) {
                        String(bytes: $0, encoding: .utf8)
                    }
                }
            }
            return list
        }
        return list
    }

    /// Helper function to create an NSError from a Unix errno.
    private static func posixError(_ err: Int32) -> NSError {
        return NSError(domain: NSPOSIXErrorDomain, code: Int(err),
                       userInfo: [NSLocalizedDescriptionKey: String(cString: strerror(err))])
    }
}
