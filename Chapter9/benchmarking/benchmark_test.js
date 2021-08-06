// import benchmark
var Benchmark = require('benchmark');
var suite = new Benchmark.Suite();

const fs = require('fs');
const bytes = fs.readFileSync('./pow2_test.wasm');
const colors = require('colors');

// Variables for WASM functions
var pow2;
var pow2_reverse;
var pow2_mul_shift;
var pow2_mul_div_shift;
var pow2_mul_div_nor;
var pow2_opt;

console.log(`
=================== RUNNING BENCHMARK ===================
`.rainbow);

function init_benchmark() {
    // adds callbacks for the benchmarks
    suite.add('#1 '.yellow + 'Original Function', pow2);
    suite.add("#2 ".yellow + 'Reversed Div/Mul order', pow2_reverse);
    suite.add("#3 ".yellow + 'Replace mult with shift', pow2_mul_shift);
    suite.add('#4 '.yellow + 'Replace mult & div with shift', pow2_mul_div_shift);
    suite.add('#5 '.yellow + 'wasm-opt version', pow2_opt);
    suite.add('#6 '.yellow + 'Use shifts with OG order', pow2_mul_div_nor);

    // add listeners
    suite.on('cycle', function(event) {
        console.log(String(event.target));
    });

    suite.on('complete', function () {
        // when benchmark is complete, log fastest and slowest
        let fast_string = ('Fastest is ' + this.filter('fastest').map('name'));
        let slow_string = ('Slowest is ' + this.filter('slowest').map('name'));
        console.log(`
        ----------------------------------------------------
        ${fast_string.green}
        ${slow_string.red}
        ----------------------------------------------------
        `);

        // create array of succesful runs and sort fast to slow
        var arr = this.filter('successful');
        arr.sort(function(a, b) {
            return a.stats.mean - b.stats.mean;
        });

        console.log(`
        
        `);
        console.log("============== FASTEST ==============");
        while (obj = arr.shift()) {
            let extension = '';
            let count = Math.ceil(1 / obj.stats.mean);

            if (count > 1000) {
                count /= 1000;
                extension = 'K'.green.bold;
            }

            if (count > 1000) {
                count /= 1000;
                extension = 'M'.green.bold;
            }

            count = Math.ceil(count);

            let count_string = count.toString().yellow + extension;
            console.log(`${obj.name.padEnd(45, ' ')} ${count_string} exec/sec`);
        }
        console.log("============== SLOWEST ==============");
    });
    suite.run({'async': false});
}

(async () => {
    const obj = await WebAssembly.instantiate(new Uint8Array(bytes));
    pow2 = obj.instance.exports.pow2;
    pow2_reverse = obj.instance.exports.pow2_reverse;
    pow2_mul_div_shift = obj.instance.exports.pow2_mul_div_shift;
    pow2_opt = obj.instance.exports.pow2_opt;
    pow2_mul_div_nor = obj.instance.exports.pow2_mul_div_nor;
    pow2_mul_shift = obj.instance.exports.pow2_mul_shift;
    init_benchmark();
})();