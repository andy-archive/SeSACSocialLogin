//
//  ViewController.swift
//  SeSACSocialLogin
//
//  Created by Taekwon Lee on 12/28/23.
//

import AuthenticationServices
import UIKit

/* 📝
 소셜 로그인(페북/구글/카카오..), 애플 로그인 구현 필수 (구현 안할 시 리젝 사유 ⛔️)
 (ex. 인스타그램은 북꺼니까(?) 애플 안붙여도 괜찮음!)
 자체 로그인만 구성이 되어 있다면, 애플 로그인 구현 필수 아님
 => 개인 개발자 계정이 있어야 테스트 가능
 */

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
    /// 첫 번째 시도: 계속 Email, fullName 제공
    /// 두 번째 시도: 로그인 할래요? Email, fullName이 nil 값으로 옴
    /// 사용자 정보를 계속 제공해주지는 않음 -> 최초만 제공 ⭐️
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print(#function)
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            print("appleIDCredential: ", appleIDCredential)
            
            let user = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            guard
                let identityToken = appleIDCredential.identityToken,
                let tokenToString = String(data: identityToken, encoding: .utf8)
            else {
                print("TOKEN ERROR")
                return
            }
            
            print("INFO: ")
            print(user)
            print(fullName ?? "No fullName")
            print(email ?? "No email")
            print(identityToken)
            print("------------------------------")
            
            if email?.isEmpty ?? true {
                let result = decode(jwtToken: tokenToString)["email"] as? String ?? ""
                print(result)
            }
            
            /// 이메일 / 토큰 / 이름 -> UserDefaults & API 서버로 POST
            /// 서버에 Request에 대한 Response를 받으면 성공 시 화면 전환
            return
        case let passwordCredential as ASPasswordCredential:
            
            let user = passwordCredential.user
            let password = passwordCredential.password
            
            print("passwordCredential: ", passwordCredential)
            print(user)
            print(password)
            print("------------------")
            
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

//MARK: - Decode
private extension ViewController{
    
    func decode(jwtToken jwt: String) -> [String: Any] {
        
        func base64UrlDecode(_ value: String) -> Data? {
            var base64 = value
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            
            let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
            let requiredLength = 4 * ceil(length / 4.0)
            let paddingLength = requiredLength - length
            if paddingLength > 0 {
                let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
                base64 = base64 + padding
            }
            return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
        }
        
        func decodeJWTPart(_ value: String) -> [String: Any]? {
            guard let bodyData = base64UrlDecode(value),
                  let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
                return nil
            }
            
            return payload
        }
        
        let segments = jwt.components(separatedBy: ".")
        
        return decodeJWTPart(segments[1]) ?? [:]
    }
}
