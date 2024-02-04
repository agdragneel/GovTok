const GovTok=artifacts.require('GovTok')
module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(GovTok,1000000)
};
  