//
//  TestLexiconBytes.swift
//  ATProtoLiteClient
//
//  Created by Mark @ Germ on 2/9/26.
//

import ATProtoLiteClient
import Foundation
import Testing

struct TestLexiconBytes {
	static let valid =
		"""
		  {
		  "$type": "com.germnetwork.declaration",
		  "version": "1.0.0",
		  "messageMe": {
		   "messageMeUrl": "https://landing.ger.mx/newUser",
		   "showButtonTo": "usersIFollow"
		  },
		  "currentKey": {
		   "$bytes": "A/0EngaRSOSZBNHKRYs2/cTMcePUEe+vmPy6BxZ+itX9"
		  },
		  "keyPackage": {
		   "$bytes": "AM/yCQ1RT2g/ZXGPKfKY5/1XJOlPiYLIhSuwLARf5uG3x6lUP5z5tKH17heatExOMOl43hlHEliYZiBTuuWgzgP/AaUAAQPPJd5Yr/R6BL+XG9VSSauXnbMbyeRpqqe8wrt4gM+/DwICAAAB/wE5AAEABQABAAMgDb5RmTQBiXCgQmNuelJs/ciQO3RrN+wjPnCP6t12inEgoM5Mj5grUWYh6ztDkXLzSHqtKotAZpJCkijUBMtdI0IgRuyeQ2LfmQR5VWfdE38dxMeQrJ+/QPujPslAZyl9JI4AASEDzyXeWK/0egS/lxvVUkmrl52zG8nkaaqnvMK7eIDPvw8CAAEKAAIABwAFAAEAAwAAAgABAQAAAABpe6MNAAAAAGtc1o0AQEBrnIVQ9Sh9aGUSELPjcqQwYoqdLEi3THB1+E7x+FgQs+mmG7UmfjrwPDNY1gFzkCDYi/fDi4JKko+KFK4DSRAFAEBASeLpO9OTy73ZM/kBv+XSFJ2PC/l4Y4NoMn0nJQL7f4fXrhz+2GcyflOPhV8Hx2Lf3xdWL8aUwIQ3cvp8IIBaAAABDz4xNW1mQY/QIel4fqFRJ3fWy/KIF1ocHgWuDHYn2yx7yyLxzfw7Cjfvw3vOFNJi2qF72g22+c6i0wU+xaoF"
		  }
		  }
		"""

	static let invalid =
		"""
		  {
		  "$type": "com.germnetwork.declaration",
		  "version": "1.0.0",
		  "messageMe": {
		   "messageMeUrl": "https://landing.ger.mx/newUser",
		   "showButtonTo": "usersIFollow"
		  },
		  "currentKey": "A/0EngaRSOSZBNHKRYs2/cTMcePUEe+vmPy6BxZ+itX9",
		  "keyPackage": "AM/yCQ1RT2g/ZXGPKfKY5/1XJOlPiYLIhSuwLARf5uG3x6lUP5z5tKH17heatExOMOl43hlHEliYZiBTuuWgzgP/AaUAAQPPJd5Yr/R6BL+XG9VSSauXnbMbyeRpqqe8wrt4gM+/DwICAAAB/wE5AAEABQABAAMgDb5RmTQBiXCgQmNuelJs/ciQO3RrN+wjPnCP6t12inEgoM5Mj5grUWYh6ztDkXLzSHqtKotAZpJCkijUBMtdI0IgRuyeQ2LfmQR5VWfdE38dxMeQrJ+/QPujPslAZyl9JI4AASEDzyXeWK/0egS/lxvVUkmrl52zG8nkaaqnvMK7eIDPvw8CAAEKAAIABwAFAAEAAwAAAgABAQAAAABpe6MNAAAAAGtc1o0AQEBrnIVQ9Sh9aGUSELPjcqQwYoqdLEi3THB1+E7x+FgQs+mmG7UmfjrwPDNY1gFzkCDYi/fDi4JKko+KFK4DSRAFAEBASeLpO9OTy73ZM/kBv+XSFJ2PC/l4Y4NoMn0nJQL7f4fXrhz+2GcyflOPhV8Hx2Lf3xdWL8aUwIQ3cvp8IIBaAAABDz4xNW1mQY/QIel4fqFRJ3fWy/KIF1ocHgWuDHYn2yx7yyLxzfw7Cjfvw3vOFNJi2qF72g22+c6i0wU+xaoF"
		  }
		"""

	@Test func testDecode() async throws {
		let decodedValid = try JSONDecoder().decode(
			GermLexicon.MessagingDelegateRecord.self,
			from: Self.valid.utf8Data
		)

		let decodedInvalid = try JSONDecoder().decode(
			GermLexicon.MessagingDelegateRecord.self,
			from: Self.invalid.utf8Data
		)
	}

}
