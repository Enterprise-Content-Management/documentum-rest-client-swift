//
//  RestService.swift
//  RestClient
//
//  Created by Song, Michyo on 3/29/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RestService {
    
    static let ENTRIES = "entries"
    static let PROPERTIES = "properties"
    static let LINKS = "links"
    static let MIME_JSON = "application/vnd.emc.documentum+json"
    static let MIME_MULTIPART = "multipart/form-data"
    static let MIME_JPEG = "image/jpeg"
    static let MIME_TEXT = "text/plain"
    
    // MARK: - Util
    
    private static func setPreAuth(plainString: NSString = RestUriBuilder.getCurrentLoginAuthString()) -> [String : String] {
        let plainData = plainString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "Authorization": "Basic " + base64String!
        ]
        return ["Authorization": "Basic " + base64String!]
    }
    
    private static func getPostRequestHeaders() -> [String: String] {
        var headers = self.setPreAuth()
        headers["Content-Type"] = MIME_JSON
        return headers
    }
    
    private static func getUploadRequestHeaders() -> [String: String] {
        var headers = self.setPreAuth()
        headers["Content-Type"] = MIME_MULTIPART
        return headers
    }
    
    private static func getDownloadRequestHeaders() -> [String: String] {
        let headers = self.setPreAuth()
        return headers
    }
    
    // MARK: - Basic request
    
    private static func sendRequest(
        method: Alamofire.Method,
        url: String,
        params: Dictionary<String, AnyObject>? = nil,
        headers: [String: String]? = nil,
        encoding: ParameterEncoding = .URL,
        onSuccess: (JSON) -> (),
        onFailure: (JSON) -> ()
        ) {
        Alamofire.request(method, url, parameters: params, headers: headers, encoding: encoding)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    print("Success request to \(url)")
                    if let value = response.result.value {
                        let json = JSON(value)
                        onSuccess(json)
                    }
                case .Failure:
                    let json = JSON(data: response.data!)
                    print("error: \(json)")
                    onFailure(json)
                }
        }
    }

    // MARK: - Entity Collection request
    
    private static func getEntriesOnSuccess(json: JSON, completionHandler: (NSArray?, Error?) -> ()) {
        let dictionary = json.object as! Dictionary<String, AnyObject>
        let array = dictionary[self.ENTRIES] as? NSArray
        completionHandler(array, nil)
    }
    
    private static func processFailureJson(json: JSON, completionHandler: (NSArray?, Error?) -> ()) {
        let error = Error(json: json)
        completionHandler(nil, error)
    }
    
    static func getResponseWithParams(url: String, params: [String: String], completionHandler: (NSArray?, Error?) -> ()) {
        sendRequest(.GET, url: url, params: params,
            onSuccess: { json in
                getEntriesOnSuccess(json, completionHandler: completionHandler)
            },
            onFailure: { json in
                processFailureJson(json, completionHandler: completionHandler)
            })
    }
    
    static func getResponseWithAuthAndParam(url: String, params: [String : String], completionHandler: (NSArray?, Error?) -> ()) {
        sendRequest(.GET, url: url, params: params, headers: self.setPreAuth(),
            onSuccess: { json in
                getEntriesOnSuccess(json, completionHandler: completionHandler)
            },
            onFailure: { json in
                processFailureJson(json, completionHandler: completionHandler)
        })
    }
    
    // MARK: - Single Entity request
    
    private static func getEntityOnSuccess(json: JSON, completionHandler: (RestObject?, Error?) -> ()) {
        let dictionary = json.object as! Dictionary<String, AnyObject>
        let object = RestObject(singleDic: dictionary)
        completionHandler(object, nil)
    }
    
    private static func processFailureJson(json: JSON, completionHandler: (RestObject?, Error?) -> ()) {
        let error = Error(json: json)
        completionHandler(nil, error)
    }
    
    static func getRestObject(url: String, completionHandler: (RestObject?, Error?) -> ()) {
        sendRequest(.GET, url: url, headers: self.setPreAuth(),
            onSuccess: { json in
                getEntityOnSuccess(json, completionHandler: completionHandler)
            },
            onFailure: { json in
                processFailureJson(json, completionHandler: completionHandler)
            })
    }
    
    private static func getUserOnSuccess(json: JSON, completionHandler: (User?, Error?) -> ()) {
        let dictionary = json.object as! Dictionary<String, AnyObject>
        let object = User(singleDic: dictionary)
        object.basic["definition"] = dictionary["definition"] as? String
        completionHandler(object, nil)
    }
    
    private static func processFailureJson(json: JSON, completionHandler: (User?, Error?) -> ()) {
        let error = Error(json: json)
        completionHandler(nil, error)
    }
    
    static func getUser(url: String, completionHandler: (User?, Error?) -> ()) {
        sendRequest(.GET, url: url, headers: self.setPreAuth(),
                onSuccess: { json in
                getUserOnSuccess(json, completionHandler: completionHandler)
            },
                onFailure: { json in
                processFailureJson(json, completionHandler: completionHandler)
        })
    }
    
    // MARK: - CRUD control requests
    
    private static func getStringOnSuccess(message: String, completionHandler: (String?, Error?) -> ()) {
        completionHandler(message, nil)
    }
    
    private static func processFailureJson(json: JSON, completionHandler: (String?, Error?) -> ()) {
        let error = Error(json: json)
        completionHandler(nil, error)
    }
    
    static func deleteWithAuth(url: String, completionHandler: (String?, Error?) -> ()) {
        sendRequest(.DELETE, url: url, headers: self.setPreAuth(),
            onSuccess: { json in
                getStringOnSuccess("Delete", completionHandler: completionHandler)
            },
            onFailure: { json in
                processFailureJson(json, completionHandler: completionHandler)
        })
    }
    
    static func updateWithAuth(url: String, requestBody: Dictionary<String, AnyObject>, completionHandler: (String?, Error?) -> ()) {
        sendRequest(.POST, url: url, headers: self.getPostRequestHeaders(), params: requestBody, encoding: .JSON,
            onSuccess:{ json in
                getStringOnSuccess("Update", completionHandler: completionHandler)
            },
            onFailure: { json in
                processFailureJson(json, completionHandler: completionHandler)
        })
    }
    
    private static func createEntityOnSuccess(json: JSON, completionHandler: (NSDictionary?, Error?) -> ()) {
        let dictionary = json.object as! Dictionary<String, AnyObject>
        completionHandler(dictionary, nil)
    }
    
    private static func processFailureJson(json: JSON, completionHandler: (NSDictionary?, Error?) -> ()) {
        let error = Error(json: json)
        completionHandler(nil, error)
    }
    
    static func createWithAuth(url: String, requestBody: Dictionary<String, AnyObject>, completionHandler: (NSDictionary?, Error?) -> ()) {
        sendRequest(.POST, url: url, headers: self.getPostRequestHeaders(), params: requestBody, encoding: .JSON,
            onSuccess: { json in
                createEntityOnSuccess(json, completionHandler: completionHandler)
            },
            onFailure: { json in
                processFailureJson(json, completionHandler: completionHandler)
        })
    }
    
    private static func getRepositoriesUrlOnSuccess(json: JSON, completionHandler: (String?, Error?) -> ()) {
        let resources = json["resources"].dictionary
        let repositories = resources![LinkRel.repositories.rawValue]?.dictionary
        let url = repositories!["href"]?.stringValue
        completionHandler(url, nil)
    }
    
    static func getRepositoriesUrl(completionHandler: (String?, Error?) -> ()) {
        sendRequest(.GET, url: RestUriBuilder.getServicesUrl(),
                onSuccess: { json in
                getRepositoriesUrlOnSuccess(json, completionHandler: completionHandler)
            }, onFailure: { json in
                processFailureJson(json, completionHandler: completionHandler)
            })
    }
    
    // MARK: - Upload and Downlad files
    static func uploadFile(
        url: String,
        metadata: JSON,
        file: NSData,
        type: String,
        completionHandler: (NSDictionary?, Error?) -> ()
        ) {
        Alamofire.upload(
            .POST, url, headers: self.getUploadRequestHeaders(),
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(
                    data: self.getNSDataFromJSON(metadata),
                    name: "metadata",
                    mimeType: MIME_JSON
                )
                multipartFormData.appendBodyPart(
                    data: file, name: "binary",
                    mimeType: type
                )
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.validate()
                    upload.responseJSON  { response in
                        let value = response.result.value!
                        let json = JSON(value)
                        let dic = json.object as! Dictionary<String, AnyObject>
                        completionHandler(dic, nil)
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
    static func downloadFile(
        url: String,
        objectId: String,
        completionHandler: (NSData?, Error?) -> ()
        ) {
        var fileUrl: NSURL?
        Alamofire.download(
        .GET, url,
        headers: self.getDownloadRequestHeaders()
        ) { temporaryUrl, response in
            fileUrl = FileUtil.getSaveToUrl(objectId)
            FileUtil.deleteFile(objectId)

            print("Download path: \(fileUrl!.absoluteString)")
            return fileUrl!
        }
            .response { request, response, data, error in
                if let error = error {
                    let userInfo = error.userInfo as [NSObject: AnyObject]
                    let url = userInfo["NSErrorFailingURLStringKey"] as! String
                    let parts = url.characters.split("/").map(String.init)
                    let hostname = parts[1].characters.split(":").map(String.init)[0]
                    let e = Error(msg: "A server with the specified hostname '\(hostname)' could not be recognizable by this device.")
                    print("Failed with error:\(error).")
                    completionHandler(nil, e)
                } else {
                    print("Downloaded file successfully.")
                    completionHandler(NSData(contentsOfURL: fileUrl!), nil)
                }
        }
    }
    
    static func getPropertiesAndLinks(
        method: Alamofire.Method,
        url: String,
        completionHandler: (NSDictionary?, NSArray?, NSError?) -> ()
        ) {
        Alamofire.request(method, url, headers: self.setPreAuth())
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    print("http status: Success! for get to url \(url)")
                    if let value = response.result.value {
                        let json = JSON(value)
                        let dictionary = json.object as! Dictionary<String, AnyObject>
                        let properties = dictionary[self.PROPERTIES] as! NSDictionary
                        let links = dictionary[self.LINKS] as! NSArray
                        completionHandler(properties, links, nil)
                    }
                case .Failure(let error):
                    completionHandler(nil, nil, error)
                }
        }
    }
    
    // MARK: - Misc control
    static func moveObject(
        url: String,
        requestBody: Dictionary<String, AnyObject>,
        completionHandler: (NSDictionary?, Error?) -> ()) {
        Alamofire.request(.PUT, url, parameters: requestBody, headers: self.getPostRequestHeaders(), encoding: .JSON)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    print("Success move to \(url).")
                    let json = JSON(response.result.value!)
                    completionHandler(json.object as? NSDictionary, nil)
                case .Failure:
                    let json = JSON(data: response.data!)
                    print("error: \(json)")
                    let error = Error(json: json)
                    completionHandler(nil, error)
                }
        }
    }
    
    // MARK: - Response with no content
    private static func sendRequestForResponse(
        method: Alamofire.Method,
        url: String,
        params: Dictionary<String, AnyObject>? = nil,
        headers: [String: String]? = nil,
        encoding: ParameterEncoding = .URL,
        onResponse: (String) -> ()
        ) {
        Alamofire.request(method, url, parameters: params, headers: headers, encoding: encoding)
            .validate()
            .response { request, response, data, error in
                let statusCode = response!.statusCode as Int
                let result: String!
                if error != nil {
                    let json = JSON(data: data!)
                    print("error: \(json)")
                    let e = json.object as! NSDictionary
                    result = e["message"] as! String
                } else {
                    print("Success request to \(url) with status code \(statusCode)")
                    result = "Success"
                }
                onResponse(result)
        }
    }
    
    static func addMembership(
        url: String,
        requestBody: Dictionary<String, AnyObject>,
        completionHandler: (String?, Error?) -> ()) {
        sendRequestForResponse(.POST, url: url, params: requestBody, headers: self.getPostRequestHeaders(), encoding: .JSON) { result in
            if result == "Success" {
                completionHandler("Success", nil)
            } else {
                completionHandler(nil, Error(msg: result))
            }
        }
    }

    // MARK: - Helper
    
    private static func getNSDataFromNSDictionary(dic: NSDictionary) -> NSData {
        let data = NSKeyedArchiver.archivedDataWithRootObject(dic)
        return data
    }
    
    private static func getNSDataFromJSON(json: JSON) -> NSData {
        let data: NSData?
        do {
            data = try json.rawData()
        } catch _ {
            data = nil
        }
        return data!
    }
}
