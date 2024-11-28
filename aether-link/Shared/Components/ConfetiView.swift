//
//  ConfetiView.swift
//  aether-link
//
//  Created by Luis Roberto Hernandez Robles on 25/11/24.
//

import SwiftUI

struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let confettiEmitter = CAEmitterLayer()

        confettiEmitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -10)
        confettiEmitter.emitterShape = .line
        confettiEmitter.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)

        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPink, .systemPurple, .systemYellow]
        let cells: [CAEmitterCell] = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 6
            cell.lifetime = 10.0
            cell.velocity = CGFloat(150)
            cell.velocityRange = CGFloat(50)
            cell.emissionLongitude = CGFloat.pi
            cell.spin = 3.5
            cell.spinRange = 1.0
            cell.scaleRange = 0.25
            cell.scale = 0.1
            cell.contents = UIImage(systemName: "circle.fill")?.withTintColor(color, renderingMode: .alwaysOriginal).cgImage
            return cell
        }

        confettiEmitter.emitterCells = cells
        view.layer.addSublayer(confettiEmitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            confettiEmitter.birthRate = 0
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
