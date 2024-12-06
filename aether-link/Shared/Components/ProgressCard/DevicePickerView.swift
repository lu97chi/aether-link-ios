//
//  DevicePickerView.swift
//  ÆtherL
//
//  Created by Luis Roberto Hernandez Robles on 06/12/24.
//

import SwiftUI

struct DevicePickerView: View {
    @Binding var selectedDeviceIndex: Int
    var deviceLabels: [String]

    var body: some View {
        Picker("Select Device", selection: $selectedDeviceIndex) {
            ForEach(0..<deviceLabels.count, id: \.self) { index in
                Text(deviceLabels[index]).tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
}
