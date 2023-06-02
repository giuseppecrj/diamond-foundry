import "dotenv/config";
import { ethers } from "ethers";
import { createRequire } from "module";
const require = createRequire(import.meta.url);

const provider = new ethers.JsonRpcProvider(process.env.LOCAL_RPC_URL);
const wallet = new ethers.Wallet(process.env.LOCAL_PRIVATE_KEY, provider);

async function main() {
  const { address } = require("./addresses/Hello.json");
  const { abi } = require("../out/Hello.sol/Hello.json");

  // read-write you pass wallet as third argument
  const contract = new ethers.Contract(address, abi, wallet);
  console.log(await contract.sayHello());

  contract.on("GreetingChanged", (oldGreeting, newGreeting, event) => {
    console.log(oldGreeting, newGreeting);
    event.removeListener();
  });

  const tx = await contract.setGreeting("Hola, mundo!");
  await tx.wait();
  console.log(await contract.sayHello());
}

async function sign() {
  const message = "sign into ethers.org";
  const signature = await wallet.signMessage(message);
  const recovered = ethers.verifyMessage(message, signature);
  console.log(recovered === wallet.address);
}

// main();
sign();
