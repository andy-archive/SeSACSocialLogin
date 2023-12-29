//
//  AuthenticationManager.swift
//  SeSACSocialLogin
//
//  Created by Taekwon Lee on 12/29/23.
//

import Foundation
import LocalAuthentication

/*
 - 권한 요청
   - FaceID가 없다면?
   - FaceID 도중에 변경
 */

final class AuthenticationManager {
    
    //MARK: - Singleton
    static let shared = AuthenticationManager()
    
    private init() { }
    
    //MARK: - Methods
    func auth() {
        let context = LAContext()
    }
}
