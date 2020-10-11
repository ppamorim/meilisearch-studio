//
//  MeiliSearchInstance.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 12/10/2020.
//

import Foundation
import MeiliSearch

class MeiliSearchClient {

  static let shared = MeiliSearchClient()

  var client: MeiliSearch!

  private init() { }

  func setup(hostURL: String, key: String, _ completion: @escaping (Result<(), Swift.Error>) -> Void) {
    let queue = DispatchQueue(label: "MeiliSearchClientDispatchQueue")
    queue.async { [weak self] in
      do {
        let host: String = hostURL.isEmpty ? "http://localhost:7700" : hostURL
        self?.client = try MeiliSearch(Config(hostURL: host, apiKey: key))
        DispatchQueue.main.async {
          completion(.success(()))
        }
      } catch {
        DispatchQueue.main.async {
          completion(.failure(error))
        }
      }
    }
  }

}
