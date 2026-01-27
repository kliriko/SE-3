"use strict";

const waittime = 500;

function delay(ms) {
    return new Promise(resolve => {
        setTimeout(resolve, ms);
    });
}

delay(waittime)
    .then(() => {
        console.log("Operation finished");
        console.log("Program finished");
    });
