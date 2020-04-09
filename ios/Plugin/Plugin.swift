import Foundation
import Capacitor
import AuthenticationServices

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(SignInWithApple)
public class SignInWithApple: CAPPlugin {
    var call: CAPPluginCall?

    @objc func Authorize(_ call: CAPPluginCall) {
        self.call = call

        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        } else {
            call.reject("Sign in with Apple is available on iOS 13.0+ only.")
        }
    }
}

@available(iOS 13.0, *)
extension SignInWithApple: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            call?.reject("Please, try again.")

            return
        }

		var identityToken: String? = nil
		if let identityToken1 = appleIDCredential.identityToken {
			identityToken = String(data: identityToken1, encoding: .utf8)
		}

		var authorizationCode: String? = nil
		if let authorizationCode1 = appleIDCredential.authorizationCode {
			authorizationCode = String(data: authorizationCode1, encoding: .utf8)
		}

        let result = [
            "response": [
                "user": appleIDCredential.user,
                "email": appleIDCredential.email,
                "givenName": appleIDCredential.fullName?.givenName,
                "familyName": appleIDCredential.fullName?.familyName,
                "identityToken": identityToken,
                "authorizationCode": authorizationCode
            ]
        ]

        call?.resolve(result as PluginResultData)
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        call?.reject(error.localizedDescription)
    }
}
