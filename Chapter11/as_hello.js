const fs = require('fs');
const bytes = fs.readFileSync(`${__dirname}/as_hello.wasm`);

var memory = null;

let importObject = {
    as_hello: {
        console_log: function (index) {
            // in case this is called before memory is set
            if (memory == null) {
                console.log('memory buffer is null');
                return;
            }
            // length is a 32 bit integer that is in the 4 bytes preceding index
            const len_index = index - 4;
            // must divide by 2 to get from bytes to 16-bit unicode characters.
            const len = new Uint32Array(memory.buffer, len_index, 4)[0];
            const str_bytes = new Uint16Array(memory.buffer, index, len);

            // decode utf-16 bytes array into js string
            const log_string = new TextDecoder('utf-16').decode(str_bytes);
            console.log(log_string);
        }
    },
    env: {
        abort: () => { }
    }
};

(async () => {
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);
    memory = obj.instance.exports.memory;
    obj.instance.exports.HelloWorld();
})();