//
//  AuthenticationManager.swift
//  SeSACSocialLogin
//
//  Created by Taekwon Lee on 12/29/23.
//

import Foundation
import LocalAuthentication // Face ID or Touch ID

//MARK: - Class Note
/* Face ID 📝
 (1) 권한 요청
    (a) Face ID가 없다면? (잠금 자체를 안함 || 비밀번호만 등록)
        - 다른 인증 방법을 권장 || Face ID 등록 권유
        - Face ID 이전에 비밀번호 설정이 선행되어야 함 ⭐️
            - 암호만 없는 경우는 없다
    (b) Face ID를 중간에 변경
        - domainStateData (안경 / 마스크 등의 추가는 domainStateData의 변경 X) ⭐️
 (2) 계속되는 Face ID인증 실패?
   - FallBack에 대한 처리 필요
   - 다른 인증 방법으로 처리하기
 (3) Face ID 결과는 메인스레드로 보장이 되지 않음 ⭐️
   - `DispatchQueue.main.async` 필요
 (4) 어느 화면에서 Face ID 인증 성공 시, 해당 화면은 success
    - BUT, in SwiftUI ?
        - state 변경 시 body rendering -> View의 초기화 -> 다시 인증 ⭐️
 
 📌 실제 서비스에 대한 테스트 + LSLP에 생체 인증을 연동
 - 키체인 저장 ? -> 맥에서 다 볼 수 있다 (보안 상 완벽하지 않음)
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
    /// authenticate by Face ID
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
    
    /// check is able to do Face ID
    func checkPolicy() -> Bool {
        let context = LAContext()
        let policy: LAPolicy = selectedPolicy
        let result = context.canEvaluatePolicy(policy, error: nil)
        
        return result
    }
    
    /// check if FaceID has changed
    func isFaceIDChanged() -> Bool {
        let context = LAContext()
        
        context.canEvaluatePolicy(selectedPolicy, error: nil)
        
        /// 생체 인증 정보
        guard let state = context.evaluatedPolicyDomainState
        else { return false }
        
        /// 생체 인증 정보를 UserDefaults에 저장
        /// 기존에 저장한 DomainState와 새로운 DomainState을 비교
        print(state)
        
        return false
    }
}
