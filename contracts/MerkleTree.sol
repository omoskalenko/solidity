// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity ^0.8.9;

contract MerkleTree {
    // ROOT
    // H1-2 H3-4
    // H1 H2 H3 H4
    // TX1 TX2 TX3 TX4
    bytes32[] public hashes;
    string[4] transactions = [
        "TX1: Sheldon -> John",
        "TX2: John -> Sheldon",
        "TX3: John -> Mary",
        "TX4: Mary -> Sheldon"
    ];

    constructor() {
        for (uint i = 0; i < transactions.length; i++) {
            hashes.push(makeHash(transactions[i]));
        }

        uint count = transactions.length;
        uint offset = 0;

        while (count > 0) {
            for (uint i = 0; i < count - 1; i += 2) {
                hashes.push(
                    keccak256(
                        abi.encodePacked(
                            hashes[offset + i],
                            hashes[offset + i + 1]
                        )
                    )
                );
            }

            offset += count;
            count = count / 2;
        }
    }

    function verify(
        string memory transaction,
        uint index,
        bytes32 root,
        bytes32[] memory proof
    ) public pure returns (bool) {
        // "TX3: John -> Mary"
        // 2
        // 0xcf3788c49702bd28da44294387000aeadf2b26329363a07e1acda78d7234c8d4 (6)
        // ["0x5757f4ec97549f443aa0f34a942f306f6f5e66b661cd2642d53c2195c34ca8e8", "0xce8cffcfc0b715f09a20e2ab81617d4f993df61e5e3641877a3a545b89d11bbb"] (3, 4)

        bytes32 hash = makeHash(transaction);

        for (uint i = 0; i < proof.length; i++) {
            bytes32 element = proof[i];

            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, element));
            } else {
                hash = keccak256(abi.encodePacked(element, hash));
            }
            index = index / 2;
        }
        return hash == root;
    }

    function encode(string memory input) public pure returns (bytes memory) {
        return abi.encodePacked(input);
    }

    function makeHash(string memory input) public pure returns (bytes32) {
        return keccak256(encode(input));
    }
}
