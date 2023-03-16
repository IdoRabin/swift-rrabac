//
//  VaporRequestEx.swift
//  
//
//  Created by Ido on 03/07/2022.
//
#if VAPOR
import Vapor

fileprivate let dlog : DSLogger? = DLog.forClass("VaporRequestEx")

extension Vapor.Request /* App-specific components */ {
    
    static var appHasSessionMiddleWare = true
    
    // MARK: Saving info to session store
    func saveToSessionStore(key:any ReqStorageKey.Type, value:(any JSONSerializable)?) {
        guard Self.appHasSessionMiddleWare else {
            return
        }
        
        guard self.hasSession else {
            return
        }
        
        // Will also save nil (and remove that key)
        if let infoStr = value?.serializeToJsonString(prettyPrint: false) {
            self.session.data[key.asString] = infoStr
        } else {
            dlog?.warning("saveToSessionStore failed encoding \(key.asString) : \(type(of: value)) using serializeToJsonString()..")
        }
    }
    
    func getFromSessionStore<Value:JSONSerializable>(key:any ReqStorageKey.Type, required:Bool = false)->Value? {
        guard Self.appHasSessionMiddleWare else {
            return nil
        }
        
        if let infoStr = self.session.data[key.asString] {
            if let val : Value = Value.deserializeFromJsonString(string: infoStr) {
                return val
            } else {
                dlog?.warning("getFromSessionStore failed decoding \(key.asString) : \(Value.self) using deserializeFromJsonString().. raw string: \(infoStr)")
            }
        } else if required {
            dlog?.raisePreconditionFailure("getFromSessionStore failed fetching \(key.asString) : \(Value.self) value was not found in self.session.data")
        }
        return nil
    }
    
    func saveToSessionStore(userId:String?) {
        guard Self.appHasSessionMiddleWare else {
            return
        }
        
        self.saveToSessionStore(key: ReqStorageKeys.selfUserID, value: userId)
    }

    func saveToSessionStore(selfUser:User?, selfAccessToken:AccessToken?) {
        guard Self.appHasSessionMiddleWare else {
            return
        }
        
        self.saveToSessionStore(key: ReqStorageKeys.selfUser, value: selfUser)
        self.saveToSessionStore(key: ReqStorageKeys.selfAccessToken, value: selfAccessToken)
        self.saveToSessionStore(userId: selfUser?.id?.uuidString)
    }

    // MARK: Saving info to request store
    func saveToReqStore<RSK:ReqStorageKey>(key:RSK.Type, value:RSK.Value?, alsoSaveToSession:Bool = false) {
        // Will also save nil (and remove that key)
        self.storage[key] = value
        
        if alsoSaveToSession && Self.appHasSessionMiddleWare {
            if let value = value {
                if let val = value as? JSONSerializable {
                    self.saveToSessionStore(key: key, value: val)
                } else {
                    dlog?.note("saveToReqStore key [\(key.asString)] failed to save. \(type(of: value)) is not JSONSerializable. Value was = \(value)")
                }
            } else if alsoSaveToSession && Self.appHasSessionMiddleWare{
                self.saveToSessionStore(key: key, value: nil)
                
            }
        }
    }

    // MARK: Fetching info from session and req. stroage
    /// Returns the stored current self user for this request -
    /// meaning, the request had an access token and the user associaced wth that token was saved in request storage as the self user.
    func getFromReqStore<Value:JSONSerializable>(key:any ReqStorageKey.Type, getFromSessionIfNotFound:Bool = true)->Value? {
        if let anyInfo = self.storage.get(key) {
            if let info = anyInfo as? Value {
                return info
            } else {
                dlog?.note("getFromReqStore key [\(key.asString)] failed to cast as? \(Value.self). Value was: \(type(of: anyInfo)) = \(anyInfo)")
            }
        }
        
        if getFromSessionIfNotFound && Self.appHasSessionMiddleWare {
            if let infoStr = self.session.data[key.asString] {
                return Value.deserializeFromJsonString(string: infoStr)
            }
        }
        
        return nil
    }

}
extension Vapor.Request /* redirects */ {
    public enum RedirectEncoding {
        case base64
        case protobuf
        case normal
    }
    
    /// redirects the request to a new url using 3xx redirect status codes. The function is wrapped to allow interception and modification of the redirect.
    /// - Parameters:
    ///   - location: location to redirect the request to
    ///   - type: type of redirection (http statused 301, 303, 307 and their implications)
    ///   - encoding: should the redirect converts all the params to Base64 or protobuf or no conversion. (mostly used in GET redirects, where the params are visible in the URL query..)
    ///   - params:params to definately pass
    ///   - isShoudlForwardAllParams: will pass all params that we can find from this request as the arams for the redirected request. Otherwise, will forward just the params parameter, errorToForward if it exists
    ///   - errorToForward:an error to forward to the redirect as a param / or in the session route history
    ///   - contextStr: textual context of the redirect.
    /// - Returns:a response of the redirect request.
    public func wrappedRedirect(to location: String,
                                type: RedirectType = .normal,
                                encoding:RedirectEncoding = .normal,
                                params:[String:String],
                                isShoudlForwardAllParams : Bool,
                                errorToForward:AppError? = nil,
                                contextStr:String) -> Response {
        // Redictect codes: force redirect to error page:
        //   case .permanent 301  A cacheable redirect.
        //   case .normal    303  "see other" Forces the redirect to come with a GET, regardless of req method.
        //   case .temporary 307  Maintains original request method, ie: PUT will call PUT on redirect.
        var fullUrl = location;
        
        var params = params
        if isShoudlForwardAllParams && params.count == 0, let urlParams = location.asQueryParams() {
            params.merge(dict: urlParams)
        }
        if !self.hasSession {
            _ = self.session // creates a session if needed
        }
        dlog?.info("PREPARING: wrappedRedirect to: \(location.split(separator: "?").first.descOrNil) params:\(params.descriptionLines) redirect context: [\"\(contextStr)\"]")
        
        switch type {
        case .normal:
            
            // Will force a GET redirect:
            // We need to make sure to collect all the params from other places (such as body or headers) if needed:
            // Add orig Request id and sessionId to params:
            fullUrl = self.prepStatus303RedirectURL(to: fullUrl,
                                                    encoding:encoding,
                                                    params:params,
                                                    isShoudlForwardAllParams:isShoudlForwardAllParams,
                                                    context: contextStr) ?? "unknown_redirect_url"
        case .permanent:
            break
        case .temporary:
            break
        }
        
        let response : Response = self.redirect(to: fullUrl, type: type)
        self.routeHistory?.update(req: self, response: response)
        if let error = errorToForward {
            self.routeHistory?.update(req: self, error: error)
        }
        return response
    }
    
    /// Preparing the url for a 303 redirect. All the params areto be passed through the url
    /// http status / redirect 303 "see other" Forces the redirect to come with a GET, regardless of req method.
    /// NOTE: There are some params that are NEVER alowed to be passed / forwarded in a redirect: see AppSettings.shared.server?.paramKeysToNeverRedirect
    /// - Parameters:
    ///   - baseURL: the base url (path) for the redirect
    ///   - toBase64: should the parameters be counverted to base64?
    ///   - exParams: the params to definately foreard to the next request
    ///   - isShoudlForwardCurParams: should we collate all params from current request and forward them? (this will pull params from many areasof currect request and add them to the url to be requested in the 303 GET.
    ///   - context: context for the redirect - for debigging and logging purposes
    /// - Returns: the new url for a 303 GET request, including the
    public func prepStatus303RedirectURL(to baseURL: String,
                                         encoding:RedirectEncoding = .normal,
                                         params exParams:[String:String],
                                         isShoudlForwardAllParams : Bool = false,
                                         context:String) -> String? {
        
        func cleanupParams() {
            params.remove(valuesForKeys: AppSettings.shared.server?.paramKeysToNeverRedirect ?? []) // JIC
        }
        
        var result = baseURL
        
        var params : [String:String] = [:]
        params.merge(dict: exParams)
        if isShoudlForwardAllParams {
            // params.merge(dict: self.collatedAllParams())
        }
        cleanupParams()
        
        // Get also params from the baseURL if possible
        let baseURLComps = baseURL.components(separatedBy: "?")
        var path = baseURL.asNormalizedPathOnly()
        if baseURLComps.count > 1 {
            path = baseURLComps.first!
            let logPrefix = "prepStatus303RedirectURL [..\(path.lastPathComponents(count: 2))]"
            
            let query = baseURLComps[1..<baseURLComps.count].joined(separator: "?")
            var prevEncoding : Request.RedirectEncoding? = nil
            if let paramsInURL = query.removingPercentEncodingEx?.asQueryParams() {
                for (k, v) in paramsInURL {
                    if (k == AppConstants.BASE_64_PARAM_KEY) {
                        prevEncoding = .base64
                        
                        if let prms = v.explodeBase64IfPossible() {
                            params[AppConstants.BASE_64_PARAM_KEY] = nil
                            params.merge(dict: prms)
                            cleanupParams()
                        } else {
                            dlog?.note("\(logPrefix) failed exploding a base64")
                        }
                    } else if (k == AppConstants.PROTOBUF_PARAM_KEY) {
                        prevEncoding = .protobuf
                        if let prms = v.fromProtobuf()?.asQueryParams() {
                            params.merge(dict: prms)
                            cleanupParams()
                        } else {
                            dlog?.note("\(logPrefix) failed exploding a protobuf")
                        }
                        params[AppConstants.PROTOBUF_PARAM_KEY] = nil
                    } else {
                        prevEncoding = .normal
                        params[k.removingPercentEncodingEx ?? ""] = v.removingPercentEncodingEx
                    }
                }
            }
            if (baseURLComps.count > 2) { dlog?.note("\(logPrefix) Query contained more than one question mark? found: \(baseURLComps.count) parts. prevEncoding found: \(prevEncoding.descOrNil)")}
            
            // Build the url query string from all found and mutated params
            var urlQuery = ""
            if params.count > 0 {
                
                // MUTATING: Prevent some params from being redirected:
                cleanupParams()
                params.remove(valuesForKeys: [AppConstants.BASE_64_PARAM_KEY])
                
                // Create the redirection url params as a string:
                urlQuery = params.toURLQueryString(encoding:encoding)
            }

            if urlQuery.count > 0 {
                result = path + "?" + urlQuery
            }
        } else if params.count > 0 {
            params.remove(valuesForKeys: AppSettings.shared.server?.paramKeysToNeverRedirect ?? []) // JIC
            result = path + "?" + params.toURLQueryString()
        } else {
            result = path // Same as in var init, but we want to be readable and clear that in any other case we direct to this path without params
        }
        
        return result
    }
}

extension Vapor.Request /* selfUser and access token */ {
    
    static let REQUEST_UUID_STRING_PREFIX = "REQ|"
    static let URL_ESCAPE_ENCODED_DETECTION_CHARACTERSET = CharacterSet(charactersIn: "%+&=")
    
    /// Returns the request's ID: each request gets its own uuid for logging purposes.
    /// Example: "2D1ED539-CACF-4DB1-A6E6-2F8343135B3F"
    var requestUUIDString: String {
        get {
            let result : Logger.MetadataValue? = self.logger[metadataKey: "request-id"]
            if let result = result {
                switch result {
                case .string(let str):
                    return Vapor.Request.REQUEST_UUID_STRING_PREFIX + str // UUID as a string
                default:
                    dlog?.raisePreconditionFailure("Vapor.Request.requestUUIDString element was of an unexpected type.")
                }
            }
            dlog?.raisePreconditionFailure("Vapor.Request.requestUUIDString was undefined")
            preconditionFailure("Vapor.Request.requestUUIDString was undefined")
        }
    }
    
    var selfUserUUIDString: String? {
        return self.selfUserUUID?.uuidString
    }
    
    var selfUserUUID: UUID? {
        return self.selfUser?.id
    }
    
    var selfUser : User? {
        if let user : User = self.getFromReqStore(key: ReqStorageKeys.selfUser) {
            return user
        }
        
        guard let accessToken = self.getAccessToken(context: "VaporRequestEx.selfUser property") else {
            return nil
        }
        
        let result : User? = accessToken.$user.value
        if let result = result {
            // Save to req storage
            self.saveToReqStore(key: ReqStorageKeys.selfUser, value: result, alsoSaveToSession: false)
        }
        return result
    }
    
    var accessToken : AccessToken? {
        return self.getAccessToken(context: "VaporRequestEx.accessToken property")
    }
    
    private func getAccessTokenFromBearerToken(_ logPrefix:String)->AccessToken? {
        var result : AccessToken? = nil
        if result == nil, let tokenStr = self.headers.bearerAuthorization?.token ?? self.session.data[SelfAccessTokenStorageKey.asString] ?? self.session.data[AccessTokenStorageKey.asString] {
            do {
                // dlog?.success("Success getting request/session accessToken (+self user)")
                let res = try AccessToken(bearerToken: tokenStr, allowExpired: true)
                if res.isValid && !res.isEmpty {
                    self.saveToReqStore(key: ReqStorageKeys.selfAccessToken, value: result)
                    self.saveToSessionStore(key: ReqStorageKeys.selfAccessToken, value: result)
                    result = res
                }
            } catch let error {
                dlog?.warning("\(logPrefix) creation or fetchfrom request headers / storage failed with error: " + error.description)
            }
        }
        return result
    }
    
    func getAccessToken(context:String?)->AccessToken? {
        // Cached value
        guard let accessToken : AccessToken = self.getFromReqStore(key: ReqStorageKeys.selfAccessToken) else {
            self.saveToReqStore(key: ReqStorageKeys.selfAccessToken, value: AccessToken.emptyToken)
            return nil
            // Return
        }
        
        guard accessToken.isEmpty else {
            return nil
            // Return
        }
        
        // Start actual fetching:
        let logPrefix = (context?.count ?? 0 > 0) ? "getAccessToken(context: \(context ?? ""))" : "getAccessToken:"
        
        // Try getting the access token string from the bearer token or from session storage
        let result : AccessToken? = self.getAccessTokenFromBearerToken(logPrefix)
        
        if Debug.IS_DEBUG {
            if result == nil && !self.url.path.lowercased().contains(anyOf: ["/login", "login/"]) {
                // Log missing access toeken / user
                dlog?.note("\(logPrefix) req: \(self.url.path.lastPathComponents(count: 3)) Failed finding accessToken in the request/session (also self user)")
            }
        }
        
        // Save to req storage
        self.saveToReqStore(key: ReqStorageKeys.selfAccessToken, value: result ?? AccessToken.emptyToken /* all zeroes*/ , alsoSaveToSession: false)
        
        return (result?.isEmpty ?? true) ? nil : result
    }
}

extension Vapor.Request /* App-specific : route context and history */ {
    
    var routeContext : AppRouteContext? {
        return self.getFromReqStore(key: AppRouteContextStorageKey.self, getFromSessionIfNotFound: true)
    }
    
    var routeHistory : RoutingHistory? {
        return self.getFromSessionStore(key: ReqStorageKeys.appRouteHistory)
    }
    
    func getError(byReqId:String)->(err:AppError, path:String, requestId:String)? {
        var reqId = byReqId
        if reqId.contains("%") {
            reqId = reqId.removingPercentEncodingEx ?? reqId
        }
        // Get from history:
        for posi in self.routeHistory?.items ?? [] {
            if posi.requestID == reqId, let err = posi.appError {
                return (err:err, path:posi.path, requestId:posi.requestID)
            }
        }
        return nil
    }
    
    func getLastError()->(err:AppError, path:String, requestId:String)? {
        let possibles = self.routeHistory?.items.filter { item in
            if let err = item.appError {
                return err.httpStatus != HTTPStatus.ok
            } else {
                return false
            }
        } ?? []
        
        var result : (err:AppError, path:String, requestId:String)? = nil

        // Get from history:
        for posi in possibles {
            if let err = posi.appError,
                result == nil || result?.err.code ?? Int.min == HTTPStatus.ok.code {
                
                result = (err:err, path:posi.path, requestId:posi.requestID)
                break // was found...
            }
        }
        

        return result
    }
    
    var productType : RouteProductType {
        var result : RouteProductType = .unknown
        let arcontext = self.routeContext ?? AppRouteContext.setupRouteContext(for: self)

        
        // Check using route infos:
        // Get route info:
        
        // Get product type:
        
        
        // Check using route context:
        if result == .unknown && arcontext.productType != .unknown {
            result = arcontext.productType
        }
        
        // Check using GET and accept-type headers
        if result == .unknown {
            if self.method == .GET && self.headers.accept.mediaTypes.contains(where: { $0 == .html }) {
                result = .webPage
            }
        }
        
        return result
    }
}

#endif // ======================
