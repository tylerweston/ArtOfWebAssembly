// assembly script loader has a bunch of helper functions to make
// interacting with assemblyscript a lot easier!
const loader = require('@assemblyscript/loader');
const fs = require('fs');
var module;

const importObject = {
    as_hello: {
        console_log: (str_index) => {
            console.log(module.exports.__getString(str_index));
        }
    }
};

(async () => {
    let wasm = fs.readFileSync(`${__dirname}/as_hello.wasm`);
    module = await loader.instantiate(wasm, importObject);
    module.exports.HelloWorld();
})();