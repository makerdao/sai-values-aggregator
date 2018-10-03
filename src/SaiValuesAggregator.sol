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

import "ds-math/math.sol";

contract TubInterface {
    function vox() public view returns (VoxInterface);
    function tap() public view returns (TapInterface);
    function pip() public view returns (PipInterface);
    function pep() public view returns (PepInterface);
    function mat() public view returns (uint);
    function chi() public view returns (uint);
    function per() public view returns (uint);
    function tag() public view returns (uint);
    function axe() public view returns (uint);
    function cap() public view returns (uint);
    function fit() public view returns (uint);
    function tax() public view returns (uint);
    function fee() public view returns (uint);
    function gap() public view returns (uint);
    function rho() public view returns (uint);
    function rhi() public view returns (uint);
    function off() public view returns (bool);
    function out() public view returns (bool);
    function pit() public view returns (address);
    function gem() public view returns (TokInterface);
    function gov() public view returns (TokInterface);
    function skr() public view returns (TokInterface);
    function sai() public view returns (TokInterface);
    function sin() public view returns (TokInterface);
    function cups(bytes32) public view returns (address, uint, uint, uint);
    function tab(bytes32) public view returns (uint);
    function safe(bytes32) public view returns (bool);
}

contract TapInterface {
    function fix() public view returns (uint);
    function gap() public view returns (uint);
}

contract VoxInterface {
    function par() public view returns (uint);
    function way() public view returns (uint);
    function era() public view returns (uint);
}

contract PipInterface {
    function peek() public view returns (bytes32, bool);
}

contract PepInterface {
    function peek() public view returns (bytes32, bool);
}

contract TokInterface {
    function balanceOf(address) public view returns (uint);
    function allowance(address, address) public view returns (uint);
}

contract SaiValuesAggregator is DSMath {
    TubInterface public tub;

    constructor(address _tub) public {
        tub = TubInterface(_tub);
    }

    // Return the aggregated values from tub, vox and tap
    function aggregateValues() public view returns (
                                                        uint blockNumber,
                                                        bytes32 pip,
                                                        bool pipSet,
                                                        bytes32 pep,
                                                        bool pepSet,
                                                        bool off,
                                                        bool out,
                                                        uint[] r
                                                    ) {
        blockNumber = block.number;

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

    function aggregateTokenValues(address myAddr, address myProxy) public view returns (
                                                                                            uint blockNumber,
                                                                                            uint[] gem,
                                                                                            uint[] gov,
                                                                                            uint[] skr,
                                                                                            uint[] sai,
                                                                                            uint[] sin
                                                                                        ) {
        blockNumber = block.number;

        gem = new uint[](3);
        gem[0] = tub.gem().balanceOf(myAddr);
        gem[1] = tub.gem().balanceOf(tub);
        gem[2] = tub.gem().balanceOf(tub.tap());

        gov = new uint[](3);
        gov[0] = tub.gov().balanceOf(myAddr);
        gov[1] = tub.gov().balanceOf(tub.pit());
        gov[2] = tub.gov().allowance(myAddr, myProxy);

        skr = new uint[](3);
        skr[0] = tub.skr().balanceOf(myAddr);
        skr[1] = tub.skr().balanceOf(tub);
        skr[2] = tub.skr().balanceOf(tub.tap());

        sai = new uint[](3);
        sai[0] = tub.sai().balanceOf(myAddr);
        sai[1] = tub.sai().balanceOf(tub.tap());
        sai[2] = tub.sai().allowance(myAddr, myProxy);

        sin = new uint[](2);
        sin[0] = tub.skr().balanceOf(tub);
        sin[1] = tub.sin().balanceOf(tub.tap());
    }

    function aggregateCDPValues(bytes32 cup) public view returns (
                                                                    uint blockNumber,
                                                                    address lad,
                                                                    bool safe,
                                                                    uint[] r
                                                                ) {
        blockNumber = block.number;

        r = new uint[](8);
        (lad, r[0], r[1], r[2]) = tub.cups(cup);
        // r[0]: ink
        // r[1]: art
        // r[2]: rhi
        safe = tub.safe(cup);

        uint pro = rmul(tub.tag(), r[0]);
        r[3] = wdiv(pro, rmul(tub.vox().par(), tub.tab(cup)));
        // r[3]: ratio

        r[4] = safe ? sub(rdiv(pro, rmul(tub.mat(), tub.vox().par())), tub.tab(cup)) : 0;
        // r[4]: availDAI
        uint minSKRNeeded = rdiv(rmul(rmul(tub.tab(cup), tub.mat()), tub.vox().par()), tub.tag());
        r[5] = safe ? sub(r[0], minSKRNeeded > 0.005 ether ? minSKRNeeded : 0.005 ether) : 0;
        // r[5]: availSKR
        r[6] = rmul(r[5], tub.per());
        // r[6]: availETH
        r[7] = r[0] > 0 && r[1] > 0 ? wdiv(rdiv(rmul(tub.tab(cup), tub.mat()), tub.per()), r[0]) : 0;
        // r[7]: liqPrice
    }

    // // Return just the aggregated tub values
    // function aggregateTubValues() public view returns (bytes32 pip, bool pipSet, bytes32 pep, bool pepSet, bool off, bool out, uint[] r) {

    //     (pip, pipSet) = tub.pip().peek(); // Price feed value for gem
    //     (pep, pepSet) = tub.pep().peek(); // Price feed value for gov

    //     off = tub.off(); // Cage flag
    //     out = tub.out(); // Post cage exit

    //     r = new uint[](12);
    //     r[0] = tub.axe(); // Liquidation penalty
    //     r[1] = tub.mat(); // Liquidation ratio
    //     r[2] = tub.cap(); // Debt ceiling
    //     r[3] = tub.fit(); // REF per SKR (just before settlement)
    //     r[4] = tub.tax(); // Stability fee
    //     r[5] = tub.fee(); // Governance fee
    //     r[6] = tub.chi(); // Accumulated Tax Rates
    //     r[7] = tub.rhi(); // Accumulated Tax + Fee Rates
    //     r[8] = tub.rho(); // Time of last drip
    //     r[9] = tub.gap(); // Join-Exit Spread
    //     r[10] = tub.tag(); // Abstracted collateral price (ref per skr)
    //     r[11] = tub.per(); // Wrapper ratio (gem per skr)
    // }

    // // Return just the aggregated vox values
    // function aggregateVoxValues() public view returns (uint par, uint way, uint era) {
    //     par = tub.vox().par(); // Dai Target Price (ref per dai)
    //     way = tub.vox().way(); // The holder fee (interest rate)
    //     era = tub.vox().era();
    // }

    // // Return just the aggregated tap values
    // function aggregateTapValues() public view returns (uint fix, uint gap) {
    //     fix = tub.tap().fix(); // Cage price
    //     gap = tub.tap().gap(); // Boom-Bust Spread
    // }
}
