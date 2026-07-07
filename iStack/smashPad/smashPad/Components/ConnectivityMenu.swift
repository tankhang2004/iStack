//
//  ConnectivityMenu.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 07/07/26.
//

import SwiftUI

struct ConnectivityMenu: View {
    
    @Binding var isPresented: Bool
    @ObservedObject private var watch = ConnectivityManager.shared
    @ObservedObject private var bluetooth = BluetoothService.shared
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 18) {
            
            Text("Connected Devices")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            DeviceStatusRow(
                icon: "applewatch",
                title: "Apple Watch",
                connected: watch.isWatchConnected
            )
            
            DeviceStatusRow(
                icon: "pill",
                title: "Smart Pillow",
                connected: bluetooth.isConnected
            )
            DeviceStatusRow(
                icon: "dot.radiowaves.left.and.right",
                title: "Bluetooth",
                connected: bluetooth.isBluetoothPoweredOn
            )
            Divider()
            
            Button {
                bluetooth.scanAgain()
            } label: {
                Label("Scan Again", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .padding(22)
        .frame(width: 320)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
    }
}

#Preview("Dark") {
    ConnectivityMenu(
        isPresented: .constant(true)
    )
    .preferredColorScheme(.dark)
}
