// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "./lib/YulDeployer.sol";

interface Example {}

contract ExampleTest is Test {
    YulDeployer yulDeployer = new YulDeployer();

    Example exampleContract;

    function setUp() public {
        exampleContract = Example(yulDeployer.deployContract("Example"));
    }

    function testExample() public {
        bytes memory callDataBytes = abi.encodeWithSignature("randomBytes()");

        (bool success, bytes memory data) = address(exampleContract).call{gas: 100000, value: 0}(callDataBytes);

        assertTrue(success);
        assertEq(data, callDataBytes);
    }
}
