//
//  AuthenticationManager.swift
//  SeSACSocialLogin
//
//  Created by Taekwon Lee on 12/29/23.
//

import Foundation
import LocalAuthentication

/*
 (1) 권한 요청
    (a) Face ID가 없다면? (잠금을 아예 하지 않거나 || 비밀번호만 등록)
        - 다른 인증 방법을 권장 || Face ID 등록 권유
        - Face ID 이전에 비밀번호 설정이 선행되어야 함 ⭐️
    (b) Face ID를 중간에 변경
        - domainStateData 📝 (안경 / 마스크 추가는 domainStateData)
 (2) 계속되는 Face ID인증 실패?
   - FallBack에 대한 처리 필요
   - 다른 인증 방법으로 처리하기
 */

final class AuthenticationManager {
    
    //MARK: - Properties
    /// authenticated by biometry or device passcode
    var selectedPolicy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
    
    /// authenticated by Watch
    //var selectedPolicy: LAPolicy = .deviceOwnerAuthentication
    
    //MARK: - Singleton
    static let shared = AuthenticationManager()
    
    private init() { }
    
    //MARK: - Methods
    func authenticate() {
        let context = LAContext()
        context.localizedCancelTitle = "Face ID 인증 취소"
        context.localizedFallbackTitle = "비밀번호로 대신 인증"
        context.evaluatePolicy(
            selectedPolicy,
            localizedReason: "It requires Face ID authentication") { result, error in
                print("RESULT: \(result)")
                
                if let error {
                    let errorCode = error._code
                    let laErrorCodeValue = LAError.Code(rawValue: errorCode)!
                    let laError = LAError(laErrorCodeValue)
                    
                    print("LAERROR: \(laError)")
                }
            }
    }
}
