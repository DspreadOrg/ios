import CryptoKit

@available(iOS 13.0, *)
class SwiftGCM {
    // 解密方法（带错误处理）
    static func decrypt(
        ciphertext: Data,         // 密文数据
        key: SymmetricKey,       // 加密时使用的密钥
        iv: Data,                // 初始化向量（12字节）
        tag: Data,               // 认证标签（16字节）
        aad: Data? = nil         // 附加认证数据（可选）
    ) throws -> Data {
        // 1. 参数验证
        guard iv.count == 12 else {
            throw NSError(domain: "AESGCMError", code: 1, userInfo: [NSLocalizedDescriptionKey: "IV必须为12字节"])
        }
        guard tag.count == 16 else {
            throw NSError(domain: "AESGCMError", code: 2, userInfo: [NSLocalizedDescriptionKey: "认证标签必须为16字节"])
        }
        guard ciphertext.count > 0 else {
            throw NSError(domain: "AESGCMError", code: 3, userInfo: [NSLocalizedDescriptionKey: "密文数据不能为空"])
        }
        
        // 2. 创建密封盒（包含密文、IV和标签）
        let sealedBox: AES.GCM.SealedBox
        do {
            sealedBox = try AES.GCM.SealedBox(
                nonce: AES.GCM.Nonce(data: iv),
                ciphertext: ciphertext,
                tag: tag
            )
        } catch {
            throw NSError(domain: "AESGCMError", code: 4, userInfo: [NSLocalizedDescriptionKey: "密封盒创建失败: \(error)"])
        }
        
        // 3. 执行解密并验证
        do {
            let decryptedData = try AES.GCM.open(
                sealedBox,
                using: key,
                authenticating: aad!
            )
            return decryptedData
        } catch {
            throw NSError(domain: "AESGCMError", code: 5, userInfo: [NSLocalizedDescriptionKey: "解密失败: \(error)"])
        }
    }
}

// 辅助扩展：Data与Base64互转
extension Data {
    func toBase64() -> String {
        return base64EncodedString()
    }
}

extension String {
    func fromBase64() -> Data? {
        return Data(base64Encoded: self)
    }
}
