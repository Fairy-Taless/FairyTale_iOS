import Foundation

struct HTTPClient {

    static let shared = HTTPClient()
    
    private let session = URLSession.shared
    
    func performRequest(url: URL, method: String, headers: [String: String]? = nil, body: Data? = nil, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        
        // 공통 헤더 설정
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // JWT 토큰 포함
        if let authToken = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        // 추가 헤더 설정
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            completion(data, response, error)
        }
        task.resume()
    }
    
    // multipart/form-data => boundary 설정
    func performMultipartRequest(url: URL, method: String, headers: [String: String]? = nil, parameters: [String: String], data: Data, mimeType: String, filename: String, keyName: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = createBody(parameters: parameters, boundary: boundary, data: data, mimeType: mimeType, filename: filename, keyName: keyName)
        
        //jwt token
        if let authToken = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            completion(data, response, error)
        }
        task.resume()
    }
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    func createBody(parameters: [String: String], boundary: String, data: Data, mimeType: String, filename: String, keyName: String) -> Data {
        
        print(boundary)
        print(data)
        print(mimeType)
        print(filename)
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"\(keyName)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        print(body)
        
        return body as Data
    }
}


extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
