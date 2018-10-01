pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./SaiValuesAggregator.sol";

contract SaiValuesAggregatorTest is DSTest {
    SaiValuesAggregator aggregator;

    function setUp() public {
        aggregator = new SaiValuesAggregator();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
