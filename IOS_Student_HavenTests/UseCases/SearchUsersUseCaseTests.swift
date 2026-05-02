//
//  SearchUsersUseCaseTests.swift
//  IOS_Student_HavenTests
//
//  Created on 1/2/2025.
//

import XCTest
@testable import IOS_Student_Haven

final class SearchUsersUseCaseTests: XCTestCase {
    var sut: SearchUsersUseCase!
    var mockRepository: MockUserRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        sut = SearchUsersUseCase(userRepository: mockRepository)
        
        // Setup mock users
        mockRepository.mockUsers = [
            User(id: "1", email: "john.doe@university.edu", name: "John Doe", collegeId: "college1"),
            User(id: "2", email: "jane.smith@university.edu", name: "Jane Smith", collegeId: "college1"),
            User(id: "3", email: "john.public@college.edu", name: "John Public", collegeId: "college2"),
            User(id: "4", email: "mary.jones@school.edu", name: "Mary Jones", collegeId: "college1")
        ]
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Tests for successful searches
    
    func testSearchByFirstName_FindsMatchingUsers() async throws {
        // When
        let results = try await sut.execute(firstName: "John", email: "")
        
        // Then
        XCTAssertEqual(results.count, 2, "Should find 2 users named John")
        XCTAssertTrue(results.contains { $0.id == "1" })
        XCTAssertTrue(results.contains { $0.id == "3" })
    }
    
    func testSearchByEmail_FindsMatchingUsers() async throws {
        // When
        let results = try await sut.execute(firstName: "", email: "jane.smith@university.edu")
        
        // Then
        XCTAssertEqual(results.count, 1, "Should find exactly 1 user")
        XCTAssertEqual(results.first?.id, "2")
        XCTAssertEqual(results.first?.email, "jane.smith@university.edu")
    }
    
    func testSearchByBothNameAndEmail_FindsMatchingUsers() async throws {
        // When
        let results = try await sut.execute(firstName: "John", email: "john.doe@university.edu")
        
        // Then
        XCTAssertEqual(results.count, 1, "Should find exactly 1 user matching both criteria")
        XCTAssertEqual(results.first?.id, "1")
    }
    
    func testSearchIsCaseInsensitive() async throws {
        // When
        let results = try await sut.execute(firstName: "JOHN", email: "")
        
        // Then
        XCTAssertEqual(results.count, 2, "Search should be case-insensitive")
    }
    
    func testSearchTrimsWhitespace() async throws {
        // When
        let results = try await sut.execute(firstName: "  John  ", email: "  ")
        
        // Then
        XCTAssertEqual(results.count, 2, "Should trim whitespace from search terms")
    }
    
    func testSearchWithPartialEmail_FindsMatches() async throws {
        // When
        let results = try await sut.execute(firstName: "", email: "university.edu")
        
        // Then
        XCTAssertEqual(results.count, 2, "Should find users with university.edu in email")
    }
    
    // MARK: - Tests for validation errors
    
    func testSearchWithEmptyFields_ThrowsError() async {
        // When/Then
        do {
            _ = try await sut.execute(firstName: "", email: "")
            XCTFail("Should throw invalidSearchCriteria error")
        } catch let error as SearchUsersError {
            XCTAssertEqual(error, .invalidSearchCriteria)
        } catch {
            XCTFail("Should throw SearchUsersError.invalidSearchCriteria")
        }
    }
    
    func testSearchWithOnlyWhitespace_ThrowsError() async {
        // When/Then
        do {
            _ = try await sut.execute(firstName: "   ", email: "   ")
            XCTFail("Should throw invalidSearchCriteria error")
        } catch let error as SearchUsersError {
            XCTAssertEqual(error, .invalidSearchCriteria)
        } catch {
            XCTFail("Should throw SearchUsersError.invalidSearchCriteria")
        }
    }
    
    func testSearchWithValidEmailFormat() async throws {
        // When
        let results = try await sut.execute(firstName: "", email: "test@example.com")
        
        // Then - Should not throw and return empty results (no matches in mock data)
        XCTAssertEqual(results.count, 0)
    }
    
    // MARK: - Tests for network errors
    
    func testSearchHandlesNetworkError() async {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = SearchUsersError.networkError
        
        // When/Then
        do {
            _ = try await sut.execute(firstName: "John", email: "")
            XCTFail("Should propagate network error")
        } catch {
            XCTAssertTrue(error is SearchUsersError)
        }
    }
}
