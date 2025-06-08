//
//  NetworkServiceTasksTests.swift
//  Todos
//
//  Created by Malik Timurkaev on 07.06.2025.
//

import XCTest
@testable import Todos

class NetworkServiceTasksTests: XCTestCase {
    
    var sut: NetworkServiceTasks!
    
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        sut = NetworkServiceTasks(config: config)
    }
    
    override func tearDown() {
        sut = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    
    func testFetchTasksSuccess() {
        let expectation = XCTestExpectation(description: "Fetch tasks success")
        let jsonData = """
        {
            "todos": [
                {
                    "todo": "Buy milk",
                    "completed": false
                },
                {
                    "todo": "Do homework",
                    "completed": true
                }
            ]
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: EndPoint.baseServer.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, jsonData)
        }
        
        sut.fetchTasks { result in

            switch result {
            case .success(let tasks):
                XCTAssertEqual(tasks.count, 2)
                XCTAssertEqual(tasks[0].todo, "Buy milk")
                XCTAssertEqual(tasks[1].todo, "Do homework")
                XCTAssertFalse(tasks[0].isCompleted)
                XCTAssertTrue(tasks[1].isCompleted)
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success, got failure")
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchTasksServerError() {
        let expectation = XCTestExpectation(description: "Fetch tasks server error")
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: EndPoint.baseServer.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        sut.fetchTasks { result in

            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                if case .serverError(let code) = error {
                    XCTAssertEqual(code, 500)
                    expectation.fulfill()
                } else {
                    XCTFail("Expected serverError, got \(error)")
                }
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchTasksDecodingError() {
        let expectation = XCTestExpectation(description: "Fetch tasks decoding error")
        let invalidJSONData = """
        {
            "wrong_key": [
                {
                    "wrong_field": "Buy milk"
                }
            ]
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: EndPoint.baseServer.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, invalidJSONData)
        }
        
        sut.fetchTasks { result in
            
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                if case .decodingFailed = error {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected decodingFailed, got \(error)")
                }
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
}
