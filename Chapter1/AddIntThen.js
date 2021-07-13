const fs = require('fs');
const bytes = fs.readFileSync(`${__dirname} + /AddInt.wasm`);
const value_1 = parseInt(process.argv[2]);
const value_2 = parseInt(process.argv[3]);

WebAssembly.instantiate(new Uint8Array(bytes))
.then(obj => {  // wait for the return of a promise, then execute this code
    let add_value = obj.instance.exports.AddInt(value_1, value_2);
    console.log(`${value_1} + ${value_2} = ${add_value}`);
});