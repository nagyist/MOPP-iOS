//
//  OpenLdap.swift
//  CryptoLib
/*
 * Copyright 2017 - 2024 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import Foundation
import LDAP
import ASN1Decoder

public class OpenLdap {
    typealias LDAP = OpaquePointer
    typealias LDAPMessage = OpaquePointer
    typealias BerElement = OpaquePointer

    enum KeyUsage: Int {
        case digitalSignature = 0
        case nonRepudiation = 1
        case keyEncipherment = 2
        case dataEncipherment = 3
        case keyAgreement = 4
        case keyCertSign = 5
        case cRLSign = 6
        case encipherOnly = 7
        case decipherOnly = 8
    }

    static public func search(identityCode: String, configuration: MoppLdapConfiguration) async -> [Addressee] {
        var filePath: String? = nil
        if let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first {
            filePath = libraryPath.appendingPathComponent("LDAPCerts/ldapCerts.pem").path
            if !FileManager.default.fileExists(atPath: filePath!) {
                print("File ldapCerts.pem does not exist at directory path: \(filePath!)")
                filePath = nil
            }
        }

        if isPersonalCode(identityCode) {
            print("Searching with personal code from LDAP")
            return search(identityCode: identityCode, url: configuration.LDAPPERSONURL, certificatePath: filePath)
        } else {
            print("Searching with corporation keyword from LDAP")
            return search(identityCode: identityCode, url: configuration.LDAPCORPURL, certificatePath: filePath)
        }
    }

    static private func search(identityCode: String, url: String, certificatePath: String?) -> [Addressee] {
        let secureLdap = url.lowercased().hasPrefix("ldaps")
        if secureLdap {
            if let certificatePath = certificatePath, !certificatePath.isEmpty {
                guard setLdapOption(option: LDAP_OPT_X_TLS_CACERTFILE, value: certificatePath) else { return [] }
            } else {
                guard let bundlePath = Bundle(for: OpenLdap.self).resourcePath else { return [] }
                guard setLdapOption(option: LDAP_OPT_X_TLS_CACERTDIR, value: bundlePath) else { return [] }
            }
            var ldapConnectionReset = 0
            let result = ldap_set_option(nil, LDAP_OPT_X_TLS_NEWCTX, &ldapConnectionReset)
            guard result == LDAP_SUCCESS else {
                print("ldap_set_option(LDAP_OPT_X_TLS_NEWCTX) failed: \(String(cString: ldap_err2string(result)))")
                return []
            }
        }

        var ldap: LDAP?
        let ldapReturnCode = ldap_initialize(&ldap, url)
        defer {
            if let ldap = ldap { ldap_unbind_ext_s(ldap, nil, nil) }
        }
        guard ldapReturnCode == LDAP_SUCCESS else {
            print("Failed to initialize LDAP: \(String(cString: ldap_err2string(ldapReturnCode)))")
            return []
        }

        var ldapVersion = LDAP_VERSION3
        let result = ldap_set_option(ldap, LDAP_OPT_PROTOCOL_VERSION, &ldapVersion)
        guard result == LDAP_SUCCESS else {
            print("ldap_set_option(PROTOCOL_VERSION) failed: \(String(cString: ldap_err2string(result)))")
            return []
        }

        let filter = if isPersonalCode(identityCode) {
            "(serialNumber=\(secureLdap ? "PNOEE-" : "")\(identityCode))"
        } else if identityCode.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
            "(serialNumber=\(identityCode))"
        } else {
            "(cn=*\(identityCode)*)"
        }
        var msg: LDAPMessage?
        print("Searching from LDAP. Url: \(url) \(filter)")
        var attr = Array("userCertificate;binary".utf8CString)
        _ = attr.withUnsafeMutableBufferPointer { attr in
            var attrs = [attr.baseAddress, nil]
            return attrs.withUnsafeMutableBufferPointer { attrs in
                ldap_search_ext_s(ldap, "c=EE", LDAP_SCOPE_SUBTREE, filter, attrs.baseAddress, 0, nil, nil, nil, 0, &msg)
            }
        }

        if let msg = msg {
            defer { ldap_msgfree(msg) }
            var result = [Addressee]()
            var message = ldap_first_message(ldap, msg)
            while let currentMessage = message {
                if ldap_msgtype(currentMessage) == LDAP_RES_SEARCH_ENTRY {
                    result.append(contentsOf: attributes(ldap: ldap!, msg: currentMessage))
                }
                message = ldap_next_message(ldap, currentMessage)
            }
            return result
        }

        return []
    }

    static private func setLdapOption(option: Int32, value: String) -> Bool {
        let result = ldap_set_option(nil, option, value)
        if result != LDAP_SUCCESS {
            print("ldap_set_option failed: \(String(cString: ldap_err2string(result)))")
            return false
        }
        return true
    }

    static private func isPersonalCode(_ inputString: String) -> Bool {
        return inputString.count == 11 && inputString.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }

    static private func attributes(ldap: LDAP, msg: LDAPMessage) -> [Addressee] {
        var result = [Addressee]()
        var ber: BerElement?
        var attrPointer = ldap_first_attribute(ldap, msg, &ber)
        while let attr = attrPointer {
            defer { ldap_memfree(attr) }
            result.append(contentsOf: values(ldap: ldap, msg: msg, tag: String(cString: attr)))
            attrPointer = ldap_next_attribute(ldap, msg, ber)
        }
        if let ber = ber {
            ber_free(ber, 0)
        }

        if let namePointer = ldap_get_dn(ldap, msg) {
            print("Result (\(result.count)) \(String(cString: namePointer))")
            ldap_memfree(namePointer)
        }
        return result
    }

    static private func values(ldap: LDAP, msg: LDAPMessage, tag: String) -> [Addressee] {
        var result = [Addressee]()
        guard let bvals = ldap_get_values_len(ldap, msg, tag) else {
            return result
        }
        defer { ldap_value_free_len(bvals) }

        var i = 0
        while let bval = bvals[i] {
            let data = Data(bytes: bval.pointee.bv_val, count: Int(bval.pointee.bv_len))
            i += 1
            guard let x509 = try? X509Certificate(der: data) else {
                continue
            }
            var isIdCardType = false
            var isDigiIdType = false
            var isMobileID = false
            var isESeal = false
            var policyIdentifiers = [String]()
            if let ext = x509.extensionObject(oid: OID.certificatePolicies) as? X509Certificate.CertificatePoliciesExtension {
                for policy in ext.policies ?? [] {
                    policyIdentifiers.append(policy.oid)
                    switch policy.oid {
                    case let oid where oid.starts(with: "1.3.6.1.4.1.10015.1.1"),
                         let oid where oid.starts(with: "1.3.6.1.4.1.51361.1.1.1"):
                        isIdCardType = true
                    case let oid where oid.starts(with: "1.3.6.1.4.1.10015.1.2"),
                         let oid where oid.starts(with: "1.3.6.1.4.1.51361.1.1"),
                         let oid where oid.starts(with: "1.3.6.1.4.1.51455.1.1"):
                        isDigiIdType = true
                    case let oid where oid.starts(with: "1.3.6.1.4.1.10015.1.3"),
                         let oid where oid.starts(with: "1.3.6.1.4.1.10015.11.1"):
                        isMobileID = true
                    case let oid where oid.starts(with: "1.3.6.1.4.1.10015.7.3"),
                         let oid where oid.starts(with: "1.3.6.1.4.1.10015.7.1"),
                         let oid where oid.starts(with: "1.3.6.1.4.1.10015.2.1"):
                        isESeal = true
                    default:
                        break
                    }
                }
            }
            let isUnknown = !isIdCardType && !isDigiIdType && !isMobileID && !isESeal

            if x509.keyUsage[KeyUsage.keyEncipherment.rawValue] || x509.keyUsage[KeyUsage.keyAgreement.rawValue],
               !x509.extendedKeyUsage.contains(OID.serverAuth.rawValue),
               !isESeal || !x509.extendedKeyUsage.contains(OID.clientAuth.rawValue),
               !isMobileID && !isUnknown {
                let cn = x509.subject(oid: OID.commonName)?.joined(separator: ",") ?? ""
                let split = cn.split(separator: ",").map { String($0) }
                let addressee = Addressee()
                if split.count == 3 {
                    addressee.surname = split[0]
                    addressee.givenName = split[1]
                    addressee.identifier = split[2]
                } else {
                    addressee.identifier = cn
                }
                addressee.cert = data
                addressee.validTo = x509.notAfter ?? Date()
                addressee.policyIdentifiers = policyIdentifiers
                result.append(addressee)
            }
        }
        return result
    }
}
