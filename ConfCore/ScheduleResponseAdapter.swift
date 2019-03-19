//
//  ScheduleResponseAdapter.swift
//  WWDC
//
//  Created by Guilherme Rambo on 21/02/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Foundation
import SwiftyJSON

private enum ContentKeys: String, JSONSubscriptType {
    case response, rooms, tracks, sessions, events, contents, resources

    var jsonKey: JSONKey {
        return JSONKey.key(rawValue)
    }
}

final class ContentsResponseAdapter: Adapter {

    typealias InputType = JSON
    typealias OutputType = ContentsResponse

    func adapt(_ input: JSON) -> Result<ContentsResponse, AdapterError> {
        guard let eventsJson = input[ContentKeys.events].array else {
            return .failure(.missingKey(ContentKeys.events))
        }

        guard case .success(let events) = EventsJSONAdapter().adapt(eventsJson) else {
            return .failure(.invalidData)
        }

        guard let roomsJson = input[ContentKeys.rooms].array else {
            return .failure(.missingKey(ContentKeys.rooms))
        }

        guard case .success(let rooms) = RoomsJSONAdapter().adapt(roomsJson) else {
            return .failure(.invalidData)
        }

        guard let tracksJson = input[ContentKeys.tracks].array else {
            return .failure(.missingKey(ContentKeys.rooms))
        }

        guard case .success(let tracks) = TracksJSONAdapter().adapt(tracksJson) else {
            return .failure(.missingKey(ContentKeys.tracks))
        }

        guard let resourcesJSON = input[ContentKeys.resources].array else {
            return .failure(.missingKey(ContentKeys.resources))
        }

        guard case .success(let resources) = ResourcesJSONAdapter().adapt(resourcesJSON) else {
            return .failure(.invalidData)
        }

        guard let sessionsJson = input[ContentKeys.contents].array else {
            return .failure(.missingKey(ContentKeys.contents))
        }

        guard case .success(var sessions) = SessionsJSONAdapter().adapt(sessionsJson) else {
            return .failure(.invalidData)
        }

        guard case .success(let instances) = SessionInstancesJSONAdapter().adapt(sessionsJson) else {
            return .failure(.invalidData)
        }

        // remove duplicated sessions
        instances.forEach { instance in
            guard let index = sessions.firstIndex(where: { $0.identifier == instance.session?.identifier }) else { return }

            sessions.remove(at: index)
        }

        let response = ContentsResponse(events: events, rooms: rooms, tracks: tracks, resources: resources, instances: instances, sessions: sessions)

        return .success(response)
    }

}
