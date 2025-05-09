//
//  ContentView.swift
//  wkswift
//
//  Created by Marshall Thames on 4/25/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        makeGlobeView()
    }
}

func makeGlobeView() -> some View {
    let grid = Grid(resolution: 16)
    return GlobeView(grid: grid)
}

#Preview {
    ContentView()
}
