//
//  DatabaseManager.swift
//  NYU Mobility 2
//
//  Created by Jin Kim on 8/10/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import Foundation
//import FirebaseDatabase
//import SwiftyJSON

/// Manager object to read and write data to the real time Firebase database
//final class DatabaseManager {
//
//    // Referenced throughout view controllers
//    static let shared = DatabaseManager()
//
//    // Reference to the database
//    private let database = Database.database().reference()
//
//    static func safeEmail(_ emailAddress: String) -> String {
//        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
//        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
//        return safeEmail
//    }
//}
//
//extension DatabaseManager {
//
//    /// Returns dictionary node at child path
//    public func getDataFor(path: String,
//                           completion: @escaping (Result<Any, Error>) -> Void) {
//        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value else {
//                completion(.failure(DatabaseError.failedToFetch))
//                return
//            }
//            completion(.success(value))
//        }
//    }
//}
//
//// MARK: - Account Management
//extension DatabaseManager {
//
//    public enum DatabaseError: Error {
//        case failedToFetch
//
//        public var localizedDescription: String {
//            switch (self) {
//            case .failedToFetch:
//                return "Database fetching failed"
//            }
//        }
//    }
//
//    /**
//        Checks to see if a user was already inserted into the system -> in which it would return true
//        - Parameters:
//            - username: The target  username/email to look for
//            - completion: Async closure to return with result of observer
//     */
//    public func userExists(with username: String,
//                           completion: @escaping ((Bool) -> Void)) {
//        let safeEmail = DatabaseManager.safeEmail(username)
//        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
//            guard snapshot.value as? [String: Any] != nil else {
//                completion(false)
//                return
//            }
//            completion(true)
//        })
//    }
//
//    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
//        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
//            guard let value = snapshot.value as? [[String: String]] else {
//                completion(.failure(DatabaseError.failedToFetch))
//                return
//            }
//            completion(.success(value))
//        })
//    }
//
//    /// Inserts a user into the system
//    public func insertUser(with user: User,
//                                 completion: @escaping (Bool) -> Void) {
//        database.child(user.safeEmail).setValue([
//            "name": user.fullName,
//            "username": user.username,
//            "password": user.password
//            ], withCompletionBlock: {
//                [weak self] error, _ in
//                guard let strongSelf = self else {
//                    return
//                }
//                // Error inserting child
//                guard error == nil else {
//                    print("Failed to write to database")
//                    completion(false)
//                    return
//                }
//                strongSelf.database.child("users").observeSingleEvent(of: .value, with: {
//                    snapshot in
//                    if var usersCollection = snapshot.value as? [[String: String]] {
//                        // Append to user dictionary
//                        let newUser = [
//                            "name": user.fullName,
//                            "username": user.username,
//                            "password": user.password
//                        ]
//                        usersCollection.append(newUser)
//
//                        // Look for error again when inserting the array
//                        strongSelf.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
//                            guard error == nil else {
//                                completion(false)
//                                return
//                            }
//                            // User inserted successfully
//                            completion(true)
//                        })
//                    } else {
//                        // No users in that array -> create that array
//                        let newUserCollection: [[String: String]] = [
//                            [
//                                "name": user.fullName,
//                                "username": user.username,
//                                "password": user.password
//                            ]
//                        ]
//
//                        strongSelf.database.child("users").setValue(newUserCollection, withCompletionBlock: { error, _ in
//                            guard error == nil else {
//                                // Error creating array within document
//                                completion(false)
//                                return
//                            }
//
//                            // Collection created successfully
//                            completion(true)
//                        })
//                    }
//                })
//            }
//        )
//    }
//
//    /// Given the details of a session, this function will add the session under the specialists' code database
//    public func addSession(json: String, name: String, startTime: String,
//                           videoURL: String, completion: @escaping (Bool) -> Void) {
//        self.database.child("sessions").observeSingleEvent(of: .value, with: {
//            snapshot in
//            // If sessions already exists
//            if var sessions = snapshot.value as? [[String: String]] {
//                let session = [
//                    "json": json,
//                    "name": name,
//                    "startTime": startTime,
//                    "videoURL": videoURL
//                ]
//                sessions.append(session)
//                self.database.child("sessions").setValue(sessions, withCompletionBlock: {
//                    error, _ in
//                    guard error == nil else {
//                        completion(false)
//                        return
//                    }
//                    completion(true)
//                })
//            // If there have been more previous sessions tracked
//            } else {
//                let session: [[String: String]] = [
//                    [
//                    "json": json,
//                    "name": name,
//                    "startTime": startTime,
//                    "videoURL": videoURL
//                    ]
//                ]
//                self.database.child("sessions").setValue(session, withCompletionBlock: {
//                    error, _ in
//                    guard error == nil else {
//                        completion(false)
//                        return
//                    }
//                    completion(true)
//                })
//            }
//        })
//    }
//}
//
//struct User {
//    let fullName: String
//    let username: String // email address
//    let password: String
//
//    var safeEmail: String {
//        var safeEmail = username.replacingOccurrences(of: ".", with: "-")
//        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
//        return safeEmail
//    }
//}
