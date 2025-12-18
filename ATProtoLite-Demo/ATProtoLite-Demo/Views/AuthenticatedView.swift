//
//  AuthenticatedView.swift
//  ATProtoLite-Demo
//
//  Created by Mark @ Germ on 8/1/25.
//

import ATProtoLiteClient
import AuthenticationServices
import CommProtocol
import CryptoKit
import OAuthenticator
import SwiftUI
import os

///We store the handle to reduce data entry
///Progress through
///1. user enters a handle
///

//Cache values in AppStorage so as to be less annoying
struct CachedAuthenticatedView: View {
	@AppStorage("authHandle") private var storedHandle: String = ""
	@State private var viewModel = CachedAuthenticatedViewModel()

	// Relationally
	@AppStorage("otherHandle") private var otherHandle: String = ""
	@State private var blocked: Bool? = nil
	@State private var blocking: Bool? = nil
	@State private var following: Bool? = nil
	@State private var followedBy: Bool? = nil

	var body: some View {
		List {
			Section("Handle Resolution") {
				switch viewModel.state {
				case .entry(let error):
					HStack {
						TextField("@", text: $storedHandle)
						Button("Check Handle", action: check)
					}
					if let error {
						Text("Error: \(error.localizedDescription)")
							.font(.caption)
					}
					Button("Check Handle, skipping cache", action: forceRecheck)
				case .handleToDid(_):
					HStack {
						Text("Checking @\(storedHandle)...")
						ProgressView()
					}
				case .login(let loginViewModel, _):
					Text("Handle: @\(loginViewModel.handle)")
					Text("Resolves to DID \(loginViewModel.did.identifier)")
					Button("Start Over", action: viewModel.reset)
				}
			}
			if case .login(let loginViewModel, let loginStore) = viewModel.state {
				Section {
					LoginView(
						loginStore: loginStore,
						viewModel: loginViewModel
					)
				}
				if loginStore.login != nil {
					Section {
						HStack {
							Text("@")
							TextField(
								"handle.bsky.social",
								text: $otherHandle)
							Spacer()
						}
						Button("Make authed fetch") {
							Task {
								try await getMetadata(
									loginViewModel:
										loginViewModel)
							}
						}
						Button("Post messaging delegate") {
							Task {
								try await postMessagingDelegate(
									loginViewModel:
										loginViewModel)
							}
						}
						if let blocked {
							Text("Blocked: \(blocked)")
						}
						if let blocking {
							Text("Blocking: \(blocking)")
						}
						if let following {
							Text("Following: \(following)")
						}
						if let followedBy {
							Text("Followed by: \(followedBy)")
						}
					}
				}
			}
		}
	}

	func getMetadata(loginViewModel: ATProtoLiteClientViewModel) async throws {
		let theirDID = try await ATProtoPublicAPI.getTypedDID(handle: otherHandle)
		if let myPDS = try await ATProtoPublicAPI.getPds(for: loginViewModel.did.fullId),
			let pdsURL = URL(string: myPDS)
		{
			let authenticator = try await loginViewModel.getAuthenticator(
				pdsURL: pdsURL)
			let metadata = try await ATProtoAuthAPI.getAuthedMetadata(
				for: theirDID.fullId,
				pdsURL: pdsURL,
				authenticator: authenticator.authenticator
			)
			blocking = metadata.blockingURI != nil
			blocked = metadata.isBlocked
			following = metadata.followingURI != nil
			followedBy = metadata.followedByURI != nil
		}
	}

	func postMessagingDelegate(
		loginViewModel: ATProtoLiteClientViewModel
	) async throws {
		let myDID = try await ATProtoPublicAPI.getTypedDID(handle: storedHandle)
		if let myPDS = try await ATProtoPublicAPI.getPds(for: loginViewModel.did.fullId),
			let pdsURL = URL(string: myPDS)
		{
			let authenticator = try await loginViewModel.getAuthenticator(
				pdsURL: pdsURL)
			let _ = try await ATProtoAuthAPI.update(
				delegateRecord: GermLexicon.MessagingDelegateRecord(
					version: "2.3.0",
					currentKey: "testingKey".utf8Data,
					keyPackage: "testingKeyPackage".utf8Data,
					messageMe: GermLexicon.MessageMeInstructions(
						showButtonTo: .everyone,
						messageMeUrl: "message-me-url.com"
					),
					continuityProofs: ["proof1".utf8Data, "proof2".utf8Data]
				),
				for: myDID.fullId,
				pdsURL: pdsURL,
				authenticator: authenticator.authenticator
			)
		}
	}

	func check() {
		viewModel.check(storedHandle)
	}

	func forceRecheck() {
		viewModel
			.check(
				storedHandle,
				cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
			)
	}
}

//the lifetime of ATProtoLiteClientViewModel
//should be controlled by this VM

//Needs an external mechanism to get the DPoP key
//and LoginStorage for a given DID

@MainActor
@Observable class CachedAuthenticatedViewModel {
	static let logger = Logger(
		subsystem: "com.germnetwork.ATProtoLiteClient",
		category: "CachedAuthenticatedViewModel")

	enum State {
		case entry(Error?)
		case handleToDid(Task<ATProtoLiteClientViewModel, Error>)
		case login(ATProtoLiteClientViewModel, LoginStore)
	}
	private(set) var state: State = .entry(nil)

	private(set) var inMemoryStore: [ATProtoDID: LoginStore] = [:]
	private var loginSource: ATProtoLiteClientViewModel.LoginSource {
		{ did in
			if let result = self.inMemoryStore[did] {
				return result.oauthStorage
			} else {
				let result = LoginStore()
				self.inMemoryStore[did] = result
				return result.oauthStorage
			}
		}
	}

	func check(
		_ handle: String,
		cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy
	) {
		guard case .entry = state else {
			Self.logger.error("incorrect state")
			return
		}

		let task = ATProtoLiteClientViewModel.create(
			handle: handle,
			loginSource: loginSource,
			cachePolicy: cachePolicy
		)
		state = .handleToDid(task)

		Task {
			do {
				let result = try await task.value
				state =
					.login(result, inMemoryStore[result.did, default: .init()])
			} catch {
				Self.logger.logError(error, context: "checking handle")
				state = .entry(error)
			}
		}
	}

	func reset() {
		state = .entry(nil)
		for store in inMemoryStore.values {
			store.clear()
		}
		inMemoryStore = .init()
	}
}

extension CachedAuthenticatedViewModel {
	//in-memory login store
	@MainActor
	@Observable class LoginStore {
		let dPoPKey = P256.Signing.PrivateKey()
		var login: Login?

		var oauthStorage: OAuthStorage {
			.init(
				dpopKey: dPoPKey,
				retrieveLogin: { await self.login },
				storeLogin: { await self.store(login: $0) },
				clearLogin: { await self.store(login: nil) }
			)
		}

		private func store(login: Login?) {
			self.login = login
		}

		func clear() {
			self.login = nil
		}
	}
}

#Preview {
	CachedAuthenticatedView()
}
