//
//  Config.swift
//  ÆtherL
//
//  Created by Luis Roberto Hernandez Robles on 06/12/24.
//

// AppConfig.swift

import Foundation

struct AppConfig: Codable {
    let app: AppInfo
    let server: ServerConfig
    let commands: CommandsConfig
    let statuses: StatusesConfig
    let socket_events: SocketEventsConfig
    let response_properties: ResponsePropertiesConfig
}

struct AppInfo: Codable {
    let name: String
    let version: String
}

struct ServerConfig: Codable {
    let url: String
    let timeout: Int
    let periodic_refresh_interval: Int
}

struct CommandsConfig: Codable {
    let copy: String
    let erase: String
    let detect: String
    let abort: String
}

struct StatusesConfig: Codable {
    let idle: String
    let running: String
    let done: String
    let verifying: String
    let abort: String
    let error: String
    let unknown: String
}

struct SocketEventsConfig: Codable {
    let message: String
    let status: String
}

struct ResponsePropertiesConfig: Codable {
    let command: String
    let status: String
    let drive: String
    let src_dir: String
    let dest_dir: String
    let file: String
    let file_size: String
    let file_progress: String
    let proc_files: String
    let total_files: String
    let folder_size: String
    let folder_progress: String
    let elapsed_time: String
    let remaining_time: String
}
