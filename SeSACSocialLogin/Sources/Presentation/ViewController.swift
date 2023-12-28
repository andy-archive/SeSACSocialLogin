//
//  ViewController.swift
//  SeSACSocialLogin
//
//  Created by Taekwon Lee on 12/28/23.
//

import AuthenticationServices
import UIKit


final class ViewController: UIViewController {
    
    //MARK: - UI
    @IBOutlet private var appleLoginButton: ASAuthorizationAppleIDButton!
    
    //MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: - Private Methods
    private func configureUI() {
        appleLoginButton.addTarget(
            self,
            action: #selector(appleLoginButtonClicked),
            for: .touchUpInside
        )
    }
    
    //MARK: - Action
    @objc private func appleLoginButtonClicked() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

//MARK: - Delegate ASAuthorizationController
extension ViewController: ASAuthorizationControllerDelegate {
    
    /// Apple Login Success
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print(#function)
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            print("appleIDCredential: ", appleIDCredential)
            
            let user = appleIDCredential.user
            
            guard let fullName = appleIDCredential.fullName,
                  let email = appleIDCredential.email,
                  let identityToken = appleIDCredential.identityToken
            else { return }
            
            print("INFO: ", user, fullName, email, identityToken, separator: "\n")
            print()
            
            return
        case let passwordCredential as ASPasswordCredential:
            return
        default:
            break
        }
    }
    
    
    /// Apple Login Failed
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(#function)
        print("LOGIN FAILED: \(error.localizedDescription)")
    }
}

//MARK: - ASAuthorizationControllerPresentationContextProviding
extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let viewWindow = self.view.window {
            return viewWindow
        }
        return ASPresentationAnchor()
    }
}
