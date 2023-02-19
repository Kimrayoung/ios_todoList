//
//  DataType.swift
//  TodoListMission
//
//  Created by 김라영 on 2023/02/06.
//

import Foundation
import UIKit

// MARK: - 할일 목록 전체 response
struct TotalAllResponse: Codable {
    let data: [TodoAllData]?
    let meta: Meta?
    let message: String?
}

// MARK: - 할일 목록 전체 data
struct TodoAllData: Codable {
    let id: Int?
    let title, content: String?
    let images: [Image]?
    let isPublished: Bool?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, content, images
        case isPublished = "is_published"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - BonResponse
struct AddATodoDataResponse: Codable {
    let data: AddATodoData?
    let message: String?
}

// MARK: - DataClass
struct AddATodoData: Codable {
    let id: Int?
    let title: String?
    let isDone: Bool?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case isDone = "is_done"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Image
struct Image: Codable {
    let url: String?
}

// MARK: - Meta
struct Meta: Codable {
    let currentPage, from, lastPage, perPage: Int?
    let to, total: Int?
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to, total
    }
}

struct Todo: Encodable {
    let title: String?
    let is_done: Bool?
}


