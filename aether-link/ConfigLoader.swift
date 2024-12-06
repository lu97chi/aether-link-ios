////
////  ConfigLoader.swift
////  ÆtherL
////
////  Created by Luis Roberto Hernandez Robles on 06/12/24.
////
//
//// ConfigurationLoader.swift
//
//import Foundation
//import Yams
//
//class ConfigurationLoader: ObservableObject {
//    static let shared = ConfigurationLoader()
//    
//    @Published var config: AppConfig?
//    
//    private init() {
//        loadConfig()
//    }
//    
//    private func loadConfig() {
//        guard let url = Bundle.main.url(forResource: "config", withExtension: "yaml") else {
//            print("⚠️ Config file not found.")
//            return
//        }
//        
//        do {
//            let yamlString = try String(contentsOf: url, encoding: .utf8)
//            let decoder = Yams.Decoder()
//            let loadedConfig = try decoder.decode(AppConfig.self, from: yamlString)
//            DispatchQueue.main.async {
//                self.config = loadedConfig
//                print("✅ Configuration loaded successfully.")
//            }
//        } catch {
//            print("❌ Failed to load configuration: \(error)")
//        }
//    }
//}
