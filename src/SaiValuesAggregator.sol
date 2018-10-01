// SaiValuesAggregator.sol -- Sai values aggregator

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.4.24;

contract TubInterface {
    function vox() public returns (VoxInterface);
    function tap() public returns (TapInterface);
    function pip() public returns (PipInterface);
    function pep() public returns (PepInterface);
    function mat() public returns (uint);
    function chi() public returns (uint);
    function per() public returns (uint);
    function tag() public returns (uint);
    function axe() public returns (uint);
    function cap() public returns (uint);
    function fit() public returns (uint);
    function tax() public returns (uint);
    function fee() public returns (uint);
    function gap() public returns (uint);
    function rho() public returns (uint);
    function rhi() public returns (uint);
    function off() public returns (bool);
    function out() public returns (bool);
}

contract TapInterface {
    function fix() public returns (uint);
    function gap() public returns (uint);
}

contract VoxInterface {
    function par() public returns (uint);
    function way() public returns (uint);
    function era() public returns (uint);
}

contract PipInterface {
    function peek() public returns (bytes32, bool);
}

contract PepInterface {
    function peek() public returns (bytes32, bool);
}

contract SaiValuesAggregator {
    TubInterface public tub;

    constructor(address _tub) {
        tub = TubInterface(_tub);
    }

    // Return the aggregated values from tub, vox and tap
    function aggregateValues() public view returns (bytes32 pip, bool pipSet, bytes32 pep, bool pepSet, bool off, bool out, uint[] r) {

        (pip, pipSet) = tub.pip().peek(); // Price feed value for gem
        (pep, pepSet) = tub.pep().peek(); // Price feed value for gov

        off = tub.off(); // Cage flag
        out = tub.out(); // Post cage exit

        r = new uint[](17);
        // Tub
        r[0] = tub.axe(); // Liquidation penalty
        r[1] = tub.mat(); // Liquidation ratio
        r[2] = tub.cap(); // Debt ceiling
        r[3] = tub.fit(); // REF per SKR (just before settlement)
        r[4] = tub.tax(); // Stability fee
        r[5] = tub.fee(); // Governance fee
        r[6] = tub.chi(); // Accumulated Tax Rates
        r[7] = tub.rhi(); // Accumulated Tax + Fee Rates
        r[8] = tub.rho(); // Time of last drip
        r[9] = tub.gap(); // Join-Exit Spread
        r[10] = tub.tag(); // Abstracted collateral price (ref per skr)
        r[11] = tub.per(); // Wrapper ratio (gem per skr)
        // Vox
        r[12] = tub.vox().par(); // Dai Target Price (ref per dai)
        r[13] = tub.vox().way(); // The holder fee (interest rate)
        r[14] = tub.vox().era();
        // Tap
        r[15] = tub.tap().fix(); // Cage price
        r[16] = tub.tap().gap(); // Boom-Bust Spread
    }

    // Return just the aggregated tub values
    function aggregateTubValues() public view returns (bytes32 pip, bool pipSet, bytes32 pep, bool pepSet, bool off, bool out, uint[] r) {

        (pip, pipSet) = tub.pip().peek(); // Price feed value for gem
        (pep, pepSet) = tub.pep().peek(); // Price feed value for gov

        off = tub.off(); // Cage flag
        out = tub.out(); // Post cage exit

        r = new uint[](12);
        r[0] = tub.axe(); // Liquidation penalty
        r[1] = tub.mat(); // Liquidation ratio
        r[2] = tub.cap(); // Debt ceiling
        r[3] = tub.fit(); // REF per SKR (just before settlement)
        r[4] = tub.tax(); // Stability fee
        r[5] = tub.fee(); // Governance fee
        r[6] = tub.chi(); // Accumulated Tax Rates
        r[7] = tub.rhi(); // Accumulated Tax + Fee Rates
        r[8] = tub.rho(); // Time of last drip
        r[9] = tub.gap(); // Join-Exit Spread
        r[10] = tub.tag(); // Abstracted collateral price (ref per skr)
        r[11] = tub.per(); // Wrapper ratio (gem per skr)
    }

    // Return just the aggregated vox values
    function aggregateVoxValues() public view returns (uint par, uint way, uint era) {
        par = tub.vox().par(); // Dai Target Price (ref per dai)
        way = tub.vox().way(); // The holder fee (interest rate)
        era = tub.vox().era();
    }

    // Return just the aggregated tap values
    function aggregateTapValues() public view returns (uint fix, uint gap) {
        fix = tub.tap().fix(); // Cage price
        gap = tub.tap().gap(); // Boom-Bust Spread
    }
}
