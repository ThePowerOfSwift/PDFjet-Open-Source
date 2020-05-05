/**
 *  Chunk.swift
 *
Copyright (c) 2018, Innovatics Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and / or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
import Foundation


class Chunk {

    var type: [UInt8]?
    private var length: UInt32?
    private var data: [UInt8]?
    private var crc: UInt32?


    func getLength() -> UInt32? {
        return self.length
    }


    func setLength(_ length: UInt32?) {
        self.length = length
    }


    func setType(_ type: [UInt8]?) {
        self.type = type
    }


    func getData() -> [UInt8]? {
        return self.data
    }


    func setData(_ data: [UInt8]?) {
        self.data = data
    }


    func getCrc() -> UInt32? {
        return self.crc
    }


    func setCrc(_ crc: UInt32?) {
        self.crc = crc
    }


    func hasGoodCRC() -> Bool {
        let crc = CRC32()
        crc.update(type!, 0, 4)
        crc.update(data!, 0, Int(length!))
        return crc.getValue() == self.crc
    }

}   // End of Chunk.swift
