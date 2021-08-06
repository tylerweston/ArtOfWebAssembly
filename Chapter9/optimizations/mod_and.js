const fs = require('fs');
const { start } = require('repl');
const bytes = fs.readFileSync('./mod_and-opt.wasm');

(async () => {
    const obj = await WebAssembly.instantiate(new Uint8Array(bytes));
    let mod = obj.instance.exports.mod;
    let and = obj.instance.exports.and;

    let start_time = Date.now();    // reset start_time
    // the | 0 syntax is a hint to JS to use integers. Can improve performance sometimes.
    for (let i = 0 | 0; i < 4_000_000; i++) {
        mod(i);
    }
    // calculate time it took to run 4 million mods
    console.log(`mod: ${Date.now() - start_time}`);
    start_time = Date.now();

    for (let i = 0 | 0; i < 4_000_000; i++) {
        and(i);
    }
    // time to run 4 million ands
    console.log(`and: ${Date.now() - start_time}`);

    start_time = Date.now();
    for (let i = 0 | 0; i < 4_000_000; i++) {
        Math.floor(i % 1000);
    }
    console.log(`mod js: ${Date.now() - start_time}`);

    start_time = Date.now();
    for (let i = 0 | 0; i < 4_000_000; i++) {
        i & 1023;
    }
    console.log(`and js: ${Date.now() - start_time}`);  
})();