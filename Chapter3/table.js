const fs = require("fs");
const export_bytes = fs.readFileSync(`${__dirname}/table_export.wasm`);
const test_bytes = fs.readFileSync(`${__dirname}/table_test.wasm`);

let i = 0;
let increment = () => {
    i++;
    return i;
}
let decrement = () => {
    i--;
    return i;
}

const importObject = {
    js: {
        tbl: null,
        increment: increment,
        decrement: decrement,
        wasm_increment: null,
        wasm_decrement: null
    }
};

(async () => {
    let table_exp_obj = await WebAssembly.instantiate(new Uint8Array(export_bytes), importObject);

    importObject.js.tbl = table_exp_obj.instance.exports.tbl;

    importObject.js.wasm_increment = table_exp_obj.instance.exports.increment;
    importObject.js.wasm_decrement = table_exp_obj.instance.exports.decrement;

    let obj = await WebAssembly.instantiate(new Uint8Array(test_bytes), importObject);

    ({js_table_test, js_import_test, wasm_table_test, wasm_import_test} = obj.instance.exports);

    i = 0;
    let start = Date.now();
    js_table_test();
    let time = Date.now() - start;
    console.log(`js_table_test time=${time}`);

    i = 0;
    start = Date.now();
    js_import_test();
    time = Date.now() - start;
    console.log(`js_import_test=${time}`);

    i = 0;
    start = Date.now();
    wasm_table_test();
    time = Date.now() - start;
    console.log(`wasm_table_test=${time}`);

    i = 0;
    start = Date.now();
    wasm_import_test();
    time = Date.now() - start;
    console.log(`wasm_import_test=${time}`);

})();