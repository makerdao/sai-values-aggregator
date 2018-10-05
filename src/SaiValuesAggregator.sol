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

contract TopInterface {
    function tub() public view returns (TubInterface);
    function tap() public view returns (TapInterface);
}

contract TubInterface {
    function vox() public view returns (VoxInterface);
    function pit() public view returns (address);
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
    function totalSupply() public view returns (uint);
    function balanceOf(address) public view returns (uint);
    function allowance(address, address) public view returns (uint);
}

contract ProxyInterface {
    function owner() public view returns (address);
}

contract ProxyRegInterface {
    function proxies(address) public view returns (address);
}

contract SaiValuesAggregator is DSMath {
    TopInterface public top;
    TubInterface public tub;
    TapInterface public tap;
    VoxInterface public vox;
    address      public pit;
    PipInterface public pip;
    PepInterface public pep;
    TokInterface public gem;
    TokInterface public gov;
    TokInterface public skr;
    TokInterface public sai;
    TokInterface public sin;

    constructor(address _top) public {
        top = TopInterface(_top);
        tub = top.tub();
        tap = top.tap();
        vox = tub.vox();
        pit = tub.pit();
        pip = tub.pip();
        pep = tub.pep();
        gem = tub.gem();
        gov = tub.gov();
        skr = tub.skr();
        sai = tub.sai();
        sin = tub.sin();
    }

    function getContractsAddrs(address proxyRegistry, address addr) public view returns (
                                                                                uint blockNumber,
                                                                                address[] saiContracts,
                                                                                address proxy
                                                                            ) {
        blockNumber = block.number;
        saiContracts = new address[](12);
        saiContracts[0] = top;
        saiContracts[1] = tub;
        saiContracts[2] = tap;
        saiContracts[3] = vox;
        saiContracts[4] = pit;
        saiContracts[5] = pip;
        saiContracts[6] = pep;
        saiContracts[7] = gem;
        saiContracts[8] = gov;
        saiContracts[9] = skr;
        saiContracts[10] = sai;
        saiContracts[11] = sin;
        proxy = ProxyRegInterface(proxyRegistry).proxies(addr);
        proxy = ProxyInterface(proxy).owner() == addr ? proxy : address(0);
    }

    // Return the aggregated values from tub, vox and tap
    function aggregateValues(address addr, address proxy) public view returns (
                                                        uint blockNumber,
                                                        bytes32 pipVal,
                                                        bool pipSet,
                                                        bytes32 pepVal,
                                                        bool pepSet,
                                                        bool off,
                                                        bool out,
                                                        uint[] sValues, // System Values
                                                        uint[] tValues // Token Values
                                                    ) {
        blockNumber = block.number;

        (pipVal, pipSet) = pip.peek(); // Price feed value for gem
        (pepVal, pepSet) = pep.peek(); // Price feed value for gov

        off = tub.off(); // Cage flag
        out = tub.out(); // Post cage exit

        sValues = new uint[](17);
        // Tub
        sValues[0] = tub.axe(); // Liquidation penalty
        sValues[1] = tub.mat(); // Liquidation ratio
        sValues[2] = tub.cap(); // Debt ceiling
        sValues[3] = tub.fit(); // REF per SKR (just before settlement)
        sValues[4] = tub.tax(); // Stability fee
        sValues[5] = tub.fee(); // Governance fee
        sValues[6] = tub.chi(); // Accumulated Tax Rates
        sValues[7] = tub.rhi(); // Accumulated Tax + Fee Rates
        sValues[8] = tub.rho(); // Time of last drip
        sValues[9] = tub.gap(); // Join-Exit Spread
        sValues[10] = tub.tag(); // Abstracted collateral price (ref per skr)
        sValues[11] = tub.per(); // Wrapper ratio (gem per skr)
        // Vox
        sValues[12] = vox.par(); // Dai Target Price (ref per dai)
        sValues[13] = vox.way(); // The holder fee (interest rate)
        sValues[14] = vox.era();
        // Tap
        sValues[15] = tap.fix(); // Cage price
        sValues[16] = tap.gap(); // Boom-Bust Spread

        tValues = new uint[](20);
        tValues[0] = addr.balance;
        tValues[1] = gem.totalSupply();
        tValues[2] = gem.balanceOf(addr);
        tValues[3] = gem.balanceOf(tub);
        tValues[4] = gem.balanceOf(tap);

        tValues[5] = gov.totalSupply();
        tValues[6] = gov.balanceOf(addr);
        tValues[7] = gov.balanceOf(pit);
        tValues[8] = gov.allowance(addr, proxy);

        tValues[9] = skr.totalSupply();
        tValues[10] = skr.balanceOf(addr);
        tValues[11] = skr.balanceOf(tub);
        tValues[12] = skr.balanceOf(tap);

        tValues[13] = sai.totalSupply();
        tValues[14] = sai.balanceOf(addr);
        tValues[15] = sai.balanceOf(tap);
        tValues[16] = sai.allowance(addr, proxy);

        tValues[17] = sin.totalSupply();
        tValues[18] = sin.balanceOf(tub);
        tValues[19] = sin.balanceOf(tap);
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
        r[3] = wdiv(pro, rmul(vox.par(), tub.tab(cup)));
        // r[3]: ratio

        r[4] = safe ? sub(rdiv(pro, rmul(tub.mat(), vox.par())), tub.tab(cup)) : 0;
        // r[4]: availDAI
        uint minSKRNeeded = rdiv(rmul(rmul(tub.tab(cup), tub.mat()), vox.par()), tub.tag());
        r[5] = safe ? sub(r[0], minSKRNeeded > 0.005 ether ? minSKRNeeded : 0.005 ether) : 0;
        // r[5]: availSKR
        r[6] = rmul(r[5], tub.per());
        // r[6]: availETH
        r[7] = r[0] > 0 && r[1] > 0 ? wdiv(rdiv(rmul(tub.tab(cup), tub.mat()), tub.per()), r[0]) : 0;
        // r[7]: liqPrice
    }
}
