//
//  ContentView.swift
//  ATProtoLite-Demo
//
//  Created by Mark @ Germ on 8/1/25.
//

import SwiftUI

struct ContentView: View {
	var body: some View {
		TabView {
			Tab("Authenticated", systemImage: "person") {
				CachedAuthenticatedView()
			}
			Tab("Unauthenticated", systemImage: "smartphone") {
				UnauthenticatedView()
			}
		}
	}
}

#Preview {
	ContentView()
}
