//
//  Model.swift
//  001-combine-model-observations
//
//  Created by Neil Smith on 29/03/2020.
//  Copyright © 2020 Neil Smith Design LTD. All rights reserved.
//

import Foundation
import Combine

final class Model {
    
    init() {}
    
    /// Data
    private (set) var items: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    /// The published 'change' property.
    /// Using a PassthroughSubject as we only care about the output
    /// value at the moment of publishing (i.e. when a model change happens).
    private (set) var onChange: PassthroughSubject<Change, Never> = .init()

    
    /// After validating the request and mutating the model, publish the change.
    func insert(item: Int, at indexPath: IndexPath) {
        let validRow = max(0, min(indexPath.row, items.count))
        items.insert(item, at: validRow)
        onChange.send(.insertedAt([IndexPath(row: validRow, section: 0)]))
    }
    
    
    /// After validating the request and mutating the model, publish the change.
    func delete(itemAt indexPath: IndexPath) {
        guard indexPath.row >= 0 && indexPath.row < items.count else { return }
        items.remove(at: indexPath.row)
        onChange.send(.deletedAt([indexPath]))
    }
    
    
    /// Convenience type for describing the model change.
    /// Could be extended to cover all CRUD operations.
    enum Change {
        case insertedAt([IndexPath])
        case deletedAt([IndexPath])
    }
}


// MARK: - Model updates broadcasted by NotificationCenter
private extension Model {
    
    func sendNotification(for change: Change) {
        NotificationCenter.default.post(
            name: .myModelDidChange,
            object: self,
            userInfo: [Model.Change.userInfoKey : change]
        )
    }
    
}

extension Notification.Name {
    
    static var myModelDidChange: Self { .init("com.DeveloperName.Project.MyModelDidChange") }
    
}

extension Model.Change {
    
    static var userInfoKey: String { "my.model.change" }
    
}
