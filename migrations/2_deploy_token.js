var Yield = artifacts.require('../contracts/YieldToken.sol');
var Lions = artifacts.require('../contracts/Lions.sol');

module.exports = async function(deployer) {
    console.log('Deployer: ', deployer.networks[deployer.network]);
    await deployer.deploy(Yield);

    console.log('YieldToken is deployed', Yield.address);


}