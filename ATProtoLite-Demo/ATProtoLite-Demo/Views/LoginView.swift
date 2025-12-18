//
//  LoginView.swift
//  ATProtoLite-Demo
//
//  Created by Mark @ Germ on 8/1/25.
//

import ATProtoLiteClient
import CommProtocol
import OAuthenticator
import SwiftUI
import os

//ATProtoLiteClientViewModel can't actually tell you if a login exists without
//async consulting its LoginStorage

struct LoginView: View {
	static let logger = Logger(
		subsystem: "com.germnetwork.ATProtoLiteClient",
		category: "LoginView")
	//hold onto the @MainActor underlying Login Store so we can show
	//its lifecyce
	let loginStore: CachedAuthenticatedViewModel.LoginStore
	let viewModel: ATProtoLiteClientViewModel

	@State private var pds: String? = nil

	@State private var authenticatingTask: Task<Void, Error>? = nil

	var body: some View {
		Group {
			//This would normally be automatically sequenced, but
			//making this manual for the sake of testbed
			if authenticatingTask == nil {
				Button("Login", action: login)
			} else {
				HStack {
					Text("Authenticating....")
					ProgressView()
				}
			}

			if let pds {
				Text("PDS: \(pds)")
			}

			if loginStore.login == nil {
				Text("No Login")
			} else {
				Text("Login Set")
				Button("Clear Login", action: viewModel.clearLogin)
			}

			//the authenticator is an actor which is hard to introspect
			//from @MainActor
			if viewModel._authenticator == nil {
				Text("No Authenticator")
			} else {
				Text("Authenticator Set")
			}
		}
	}

	func login() {
		guard authenticatingTask == nil else {
			Self.logger.error("Can't login with pending task")
			return
		}

		let authenticatingTask = Task {
			let pds = try await ATProtoPublicAPI.getPds(
				for: viewModel.did.fullId
			)
			self.pds = pds

			let pdsURL = try URL(string: pds.tryUnwrap).tryUnwrap

			try await viewModel.getAuthenticator(pdsURL: pdsURL)
				.authenticator
				.authenticate()
		}
		self.authenticatingTask = authenticatingTask

		Task {
			do {
				let _ = try await authenticatingTask.value
				self.authenticatingTask = nil
			} catch {
				Self.logger.logError(error, context: "authenticating")
				self.authenticatingTask = nil
			}
		}
	}
}

#Preview {
	let loginStore = CachedAuthenticatedViewModel.LoginStore()
	let viewModel = ATProtoLiteClientViewModel(
		handle: "@germnetwork.com",
		did: try! .init(fullId: "did:plc:4yvwfwxfz5sney4twepuzdu7"),
		oauthStorage: loginStore.oauthStorage
	)

	LoginView(
		loginStore: loginStore,
		viewModel: viewModel
	)
}
