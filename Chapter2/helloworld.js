const fs = require('fs');
const bytes = fs.readFileSync(`${__dirname}/helloworld.wasm`);

let hello_world = null; // function will be set later
let start_string_index = 100;   // linear memory location of string, note 100 is arbitrary, 
                                // just don't want to be too far up the 64kb limit or we will run out of memory
let memory = new WebAssembly.Memory({ initial: 1 });    // allocate 1 page of web assembly memory
                    // you can allocate up to 2gb but don't want to allocate too much memory

let importObject = {    // This will be passed to our WebAssembly
    env: {              // environment! Pass the params our function will need
        buffer: memory,
        start_string: start_string_index,
        print_string: function (str_len) {  // Our print string function
            const bytes = new Uint8Array (memory.buffer, start_string_index, str_len);  // Grab str_len bytes from memory.buffer starting at start_string_index
            const log_string = new TextDecoder('utf8').decode(bytes);                   // decode the string and console.log it
            console.log(log_string);
        }
    }
};

(async () => {
    let obj = await WebAssembly.instantiate(new Uint8Array (bytes), importObject);
    ({helloworld: hello_world} = obj.instance.exports); // pull the hello_world function from our webassembly exports
    hello_world();  // execute the hello world function!
})();