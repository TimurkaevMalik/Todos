//
//  NetworkServiceTasks.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import Foundation

protocol NetworkServiceTasksProtocol {
    func fetchTasks(_ completion: @escaping (Result<[TaskDTO], NetworkError>) -> Void)
}

final class NetworkServiceTasks: NetworkServiceTasksProtocol {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private var activeTask: URLSessionTask?
    
    init(config: URLSessionConfiguration = .default,
         decoder: JSONDecoder = JSONDecoder()) {
        
        self.session = URLSession(configuration: config)
        self.decoder = decoder
    }
    
    func fetchTasks(_ completion: @escaping (Result<[TaskDTO], NetworkError>) -> Void) {
        
        if activeTask != nil {
            activeTask?.cancel()
        }
        
        guard let url = EndPoint.baseServer.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let request = makeRequest(.get, for: url)
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            
            guard let self else { return }
            
            ///Обнуляем activeTask по завершению метода
            defer {
                self.activeTask = nil
            }
            
            if let error = error as? NSError {
                DispatchQueue.main.async {
                    completion(.failure(.serverError(error.code)))
                }
                return
            }
            
            if let response = response as? HTTPURLResponse,
               !(200...299).contains(response.statusCode) {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.serverError(response.statusCode)))
                }
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let taskList = try self.decoder.decode(TaskListDTO.self, from: data)
                
                DispatchQueue.main.async {
                    completion(.success(taskList.todos))
                }
            } catch let error as NSError {
                
                DispatchQueue.main.async {
                    completion(.failure(
                        NetworkError.decodingFailed(error.code)))
                }
            }
        }
        
        activeTask = task
        task.resume()
    }
    
    private func makeRequest(_ method: HttpMethod,
                             for url: URL) -> URLRequest {
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        return request
    }
}
