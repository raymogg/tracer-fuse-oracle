pragma solidity ^0.8.0;

import "./interfaces/BasePriceOracle.sol";
import "./interfaces/ILeveragedPool.sol";
import "./interfaces/IERC20.sol";

/**
* PoC Tracer Perpetual Pool oracle for Rari Fuse.
* @dev DO NOT USE IN PRODUCTION. NO ACCESS CONTROL IMPLEMENTED
*/
contract PerpetualPoolOracle is BasePriceOracle {

    mapping(address => address) tokenToPool;

    function price(address underlying) public view returns(uint256) {
        // lookup address of perpetual pool
        address pool = tokenToPool[underlying];

        // address not yet set, return 0
        if(pool == address(0)) {
            // price not set, return default
            return 0;
        }

        ILeveragedPool _pool = ILeveragedPool(pool);
        address[2] memory tokens =  _pool.poolTokens();
        uint256 issuedPoolTokens = IERC20(underlying).totalSupply();

        // underlying MUST equal tokens[0] or [1] due to the pool == addr(0) check
        // pool token price = collateral in pool / issued pool tokens
        if (underlying == tokens[0]) {
            // long token
            return _pool.longBalance() / issuedPoolTokens;
        } else {
            // short token
            return _pool.shortBalance() / issuedPoolTokens;
        }
        
    }

    /**
    * @notice registers a Tracer Perpetual Pool with this oracle contract
    */
    function addPool(address token, address pool) public {
        ILeveragedPool _pool = ILeveragedPool(pool);
        address[2] memory tokens =  _pool.poolTokens();
        // register the short and long token for this pool
        // long token
        tokenToPool[tokens[0]] = pool;
        // short token
        tokenToPool[tokens[1]] = pool;
    }
}