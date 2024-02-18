//
//  ProverManager.swift
//  ProofPix
//
//  Created by Sofiane Larbi on 2/17/24.
//

import Foundation

class ProverManager {
    
    static let shared = ProverManager()
    
    let url = URL(string: "http://3.231.228.92:9999")!;
    
    func proveImage(signature: Data?, image: Data?, publicKey: Data?) {
        let request = MultipartFormDataRequest(url: url)
        
        guard let providedSignature = signature, let img_buffer = image, let providedPublicKey = publicKey else {
            return
        }
        request.addDataField(named: "img_buffer", data: img_buffer, mimeType: "img/jpeg")
        request.addTextField(named: "transformations", value: "[]")
        request.addTextField(named: "signature", value: providedSignature.base64EncodedString())
        request.addTextField(named: "public_key", value: providedPublicKey.base64EncodedString())
        
        URLSession.shared.dataTask(with: request, completionHandler: {data,response,error in
            if let error {
                return
            }
            PersistenceController.shared.saveURL(url: String(decoding: data!, as: UTF8.self))
        }).resume()
    }
}

struct MultipartFormDataRequest {
    private let boundary: String = UUID().uuidString
    private var httpBody = NSMutableData()
    let url: URL

    init(url: URL) {
        self.url = url
    }

    func addTextField(named name: String, value: String) {
        httpBody.append(textFormField(named: name, value: value))
    }

    private func textFormField(named name: String, value: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=ISO-8859-1\r\n"
        fieldString += "Content-Transfer-Encoding: 8bit\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"

        return fieldString
    }

    func addDataField(named name: String, data: Data, mimeType: String) {
        httpBody.append(dataFormField(named: name, data: data, mimeType: mimeType))
    }

    private func dataFormField(named name: String,
                               data: Data,
                               mimeType: String) -> Data {
        let fieldData = NSMutableData()

        fieldData.append("--\(boundary)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"\r\n")
        fieldData.append("Content-Type: \(mimeType)\r\n")
        fieldData.append("\r\n")
        fieldData.append(data)
        fieldData.append("\r\n")

        return fieldData as Data
    }
    
    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        httpBody.append("--\(boundary)--")
        request.httpBody = httpBody as Data
        return request
    }
}

extension NSMutableData {
  func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}

extension URLSession {
    func dataTask(with request: MultipartFormDataRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    -> URLSessionDataTask {
        return dataTask(with: request.asURLRequest(), completionHandler: completionHandler)
    }
}
