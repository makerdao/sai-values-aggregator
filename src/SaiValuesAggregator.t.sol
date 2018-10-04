pragma solidity ^0.4.24;

import "sai/sai.t.sol";

import "./SaiValuesAggregator.sol";

contract SaiValuesAggregatorTest is SaiTestBase {
    SaiValuesAggregator aggregator;

    function setUp() public {
        super.setUp();
        emit log_named_address('top', top);
        aggregator = new SaiValuesAggregator(top);
    }

    function testSaiValuesAggregatorContracts() public {
        assertEq(address(aggregator.top()), address(top));
        assertEq(address(aggregator.tub()), address(tub));
        assertEq(address(aggregator.tap()), address(tap));
        assertEq(address(aggregator.vox()), address(vox));
        assertEq(address(aggregator.pit()), address(pit));
        assertEq(address(aggregator.pip()), address(pip));
        assertEq(address(aggregator.pep()), address(pep));
        assertEq(address(aggregator.gem()), address(gem));
        assertEq(address(aggregator.gov()), address(gov));
        assertEq(address(aggregator.skr()), address(skr));
        assertEq(address(aggregator.sai()), address(sai));
        assertEq(address(aggregator.sin()), address(sin));
    }

    function testSaiValuesAggregatorGetContracts() public {
        (
            ,
            address top2,
            address tub2,
            address tap2,
            address vox2,
            address pit2,
            address pip2,
            address pep2,
            address gem2,
            address gov2,
            address skr2,
            address sai2,
            address sin2
        ) = aggregator.getContractsAddrs();

        assertEq(top2, address(top));
        assertEq(tub2, address(tub));
        assertEq(tap2, address(tap));
        assertEq(vox2, address(vox));
        assertEq(pit2, address(pit));
        assertEq(pip2, address(pip));
        assertEq(pep2, address(pep));
        assertEq(gem2, address(gem));
        assertEq(gov2, address(gov));
        assertEq(skr2, address(skr));
        assertEq(sai2, address(sai));
        assertEq(sin2, address(sin));
    }

    function testSaiValuesAggregatorGetAggregatedValues() public {
        (
            ,
            bytes32 pipVal,
            bool pipSet,
            bytes32 pepVal,
            bool pepSet,
            bool off,
            bool out,
            uint[] memory sValues,
            uint[] memory tValues
        ) = aggregator.aggregateValues(address(this), address(0));

        (bytes32 pipVal2, bool pipSet2) = pip.peek();
        assertEq(pipVal, pipVal2);
        assertTrue(pipSet == pipSet2);
        (bytes32 pepVal2, bool pepSet2) = pip.peek();
        assertEq(pepVal, pepVal2);
        assertTrue(pepSet == pepSet2);

        assertTrue(off == tub.off());
        assertTrue(out == tub.out());

        assertEq(sValues[0], tub.axe());
        assertEq(sValues[1], tub.mat());
        assertEq(sValues[2], tub.cap());
        assertEq(sValues[3], tub.fit());
        assertEq(sValues[4], tub.tax());
        assertEq(sValues[5], tub.fee());
        assertEq(sValues[6], tub.chi());
        assertEq(sValues[7], tub.rhi());
        assertEq(sValues[8], tub.rho());
        assertEq(sValues[9], tub.gap());
        assertEq(sValues[10], tub.tag());
        assertEq(sValues[11], tub.per());
        assertEq(sValues[12], vox.par());
        assertEq(sValues[13], vox.way());
        assertEq(sValues[14], vox.era());
        assertEq(sValues[15], tap.fix());
        assertEq(sValues[16], tap.gap());

        assertEq(tValues[0], gem.totalSupply());
        assertEq(tValues[1], gem.balanceOf(address(this)));
        assertEq(tValues[2], gem.balanceOf(tub));
        assertEq(tValues[3], gem.balanceOf(tap));
        assertEq(tValues[4], gov.totalSupply());
        assertEq(tValues[5], gov.balanceOf(address(this)));
        assertEq(tValues[6], gov.balanceOf(pit));
        assertEq(tValues[7], gov.allowance(address(this), address(0)));
        assertEq(tValues[8], skr.totalSupply());
        assertEq(tValues[9], skr.balanceOf(address(this)));
        assertEq(tValues[10], skr.balanceOf(tub));
        assertEq(tValues[11], skr.balanceOf(tap));
        assertEq(tValues[12], sai.totalSupply());
        assertEq(tValues[13], sai.balanceOf(address(this)));
        assertEq(tValues[14], sai.balanceOf(tap));
        assertEq(tValues[15], sai.allowance(address(this), address(0)));
        assertEq(tValues[16], sin.totalSupply());
        assertEq(tValues[17], sin.balanceOf(tub));
        assertEq(tValues[18], sin.balanceOf(tap));
    }
}
