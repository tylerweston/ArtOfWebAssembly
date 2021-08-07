export function cat(str1: string, str2: string): string {
    return str1 + "|" + str2;
}
// we compile this like
// asc as_concat.ts --exportRuntime -Oz -o as_concat.wasm
// --exportRuntime is needed if we are passing strings into WebAssembly