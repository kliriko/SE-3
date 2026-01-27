"use strict";

function doOperation() {
    console.log("I want to be performed!");
}

setTimeout(doOperation, 0);

let k = 0;

function eternalLoop() {

for (let i = 0; i < 1_000_000; i++) {
    if (k % 1_000_000_000 === 0) {
        console.log(k);
    }
    k++;
}

setTimeout(eternalLoop, 0); }

eternalLoop();
