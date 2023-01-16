// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library WadLib {
    uint256 public constant MULTIPLIER = 10 ** 18;

    type Wad is uint256;

    /*
    struct Wad {
        uint256 value;
    } */

    function multWad(uint256 _number, Wad wad) internal pure returns (uint256) {
        return (_number * Wad.unwrap(wad)) / MULTIPLIER;
    }

    function divWad(uint256 _number, Wad wad) internal pure returns (uint256) {
        return (_number * MULTIPLIER) / Wad.unwrap(wad);
    }

    function fromFraction(
        uint256 numerator,
        uint256 denominator
    ) internal pure returns (Wad) {
        if (numerator == 0) {
            return Wad.wrap(0);
        }
        return Wad.wrap((numerator * MULTIPLIER) / denominator);
    }
}
