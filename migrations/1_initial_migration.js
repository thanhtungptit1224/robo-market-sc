const Migrations = artifacts.require("Migrations");

module.exports = async function (deployer) {
  const migrationsInstance = await deployer.deploy(Migrations);
  console.log(migrationsInstance)
};
