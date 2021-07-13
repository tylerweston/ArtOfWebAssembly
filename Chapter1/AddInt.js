const fs = require('fs');                                       // filesystem
const bytes = fs.readFileSync(`${__dirname}/AddInt.wasm`);      // read the local wasm file
const value_1 = parseInt(process.argv[2]);                      // take arguments from command line
const value_2 = parseInt(process.argv[3]);                      // argv[0] = node, argv[1] = name of program running

(async () => {      // use IIFE (immediaetly invoked function expression) to instantiate WebAssembly module
    // IIFE basically says "it might take a bit for our WASM function to finish, go do other stuff in the mean time"
    // (async () => {})(); says there is a promise object coming, so go do other stuff while you wait.
    const obj = await WebAssembly.instantiate(new Uint8Array (bytes));  // We read a bunch of bytes earlier using readFileSync, pass them to WebAssembly.instantiate
    let add_value = obj.instance.exports.AddInt(value_1, value_2);  // call our WebAssembly function and
    console.log(`${value_1} + ${value_2} = ${add_value}`);          // display the output
})();
