pragma solidity ^0.4.24;

import "sai/sai.t.sol";

import "proxy-registry/ProxyRegistry.sol";

import "./SaiValuesAggregator.sol";

contract SaiValuesAggregatorTest is SaiTestBase {
    SaiValuesAggregator aggregator;
    ProxyRegistry registry;
    address proxy;


    function setUp() public {
        super.setUp();
        aggregator = new SaiValuesAggregator(top);
        registry = new ProxyRegistry(new DSProxyFactory());
        proxy = registry.build();
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
        (, address[] memory saiContracts, address proxy2) = aggregator.getContractsAddrs(registry, this);

        assertEq(saiContracts[0], address(top));
        assertEq(saiContracts[1], address(tub));
        assertEq(saiContracts[2], address(tap));
        assertEq(saiContracts[3], address(vox));
        assertEq(saiContracts[4], address(pit));
        assertEq(saiContracts[5], address(pip));
        assertEq(saiContracts[6], address(pep));
        assertEq(saiContracts[7], address(gem));
        assertEq(saiContracts[8], address(gov));
        assertEq(saiContracts[9], address(skr));
        assertEq(saiContracts[10], address(sai));
        assertEq(saiContracts[11], address(sin));
        assertEq(proxy2, proxy);
    }

    function testSaiValuesAggregatorGetAggregatedValues() public {
        (
            ,
            bytes32 pipVal,
            bool pipSet,
            bytes32 pepVal,
            bool pepSet,
            bool[] memory sStatus,
            uint[] memory sValues,
            uint[] memory tValues
        ) = aggregator.aggregateValues(address(this), address(0));

        (bytes32 pipVal2, bool pipSet2) = pip.peek();
        assertEq(pipVal, pipVal2);
        assertTrue(pipSet == pipSet2);
        (bytes32 pepVal2, bool pepSet2) = pip.peek();
        assertEq(pepVal, pepVal2);
        assertTrue(pepSet == pepSet2);

        assertTrue(sStatus[0] == tub.off());
        assertTrue(sStatus[1] == tub.out());

        assertTrue(!sStatus[2]);
        assertTrue(sStatus[3]);

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

        assertEq(tValues[0], address(this).balance);
        assertEq(tValues[1], gem.totalSupply());
        assertEq(tValues[2], gem.balanceOf(address(this)));
        assertEq(tValues[3], gem.balanceOf(tub));
        assertEq(tValues[4], gem.balanceOf(tap));
        assertEq(tValues[5], gov.totalSupply());
        assertEq(tValues[6], gov.balanceOf(address(this)));
        assertEq(tValues[7], gov.balanceOf(pit));
        assertEq(tValues[8], gov.allowance(address(this), address(0)));
        assertEq(tValues[9], skr.totalSupply());
        assertEq(tValues[10], skr.balanceOf(address(this)));
        assertEq(tValues[11], skr.balanceOf(tub));
        assertEq(tValues[12], skr.balanceOf(tap));
        assertEq(tValues[13], sai.totalSupply());
        assertEq(tValues[14], sai.balanceOf(address(this)));
        assertEq(tValues[15], sai.balanceOf(tap));
        assertEq(tValues[16], sai.allowance(address(this), address(0)));
        assertEq(tValues[17], sin.totalSupply());
        assertEq(tValues[18], sin.balanceOf(tub));
        assertEq(tValues[19], sin.balanceOf(tap));
    }
}
