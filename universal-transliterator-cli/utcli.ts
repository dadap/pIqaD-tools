#!/usr/bin/env node
// @ts-check
// Transliteration tables: don't bother mapping identity relationships for
// tlhIngan-Hol <-> xifan-hol

const rl = require('readline').createInterface({
    input: process.stdin,
});

process.stdin.setEncoding('utf8');
process.on('SIGINT', () => {
    console.log();
    process.exit(0);
});

var x2p = {
    "a": "",
    "b": "",
    "c": "",
    "d": "",
    "e": "",
    "f": "",
    "g": "",
    "h": "",
    "i": "",
    "j": "",
    "k": "",
    "l": "",
    "m": "",
    "n": "",
    "o": "",
    "p": "",
    "q": "",
    "r": "",
    "s": "",
    "t": "",
    "u": "",
    "v": "",
    "w": "",
    "x": "",
    "y": "",
    "z": "",
    "0": "",
    "1": "",
    "2": "",
    "3": "",
    "4": "",
    "5": "",
    "6": "",
    "7": "",
    "8": "",
    "9": "",
    ",": "",
    ".": "",
    "`": ""
};

var x2tlh = {
    "c": "ch",
    "d": "D",
    "f": "ng",
    "g": "gh",
    "h": "H",
    "i": "I",
    "k": "q",
    "q": "Q",
    "s": "S",
    "x": "tlh",
    "z": "'"
};

function to_xifan(input: string, id: string) {
    "use strict";

    var ret = input;

    if (id === "tlhIngan-Hol") {
        // Replace {gh} with non-standard {G}, to prevent {ngh} from being
        // matched as {ng}, *{h}.
        ret = ret.replace(/gh/g, "G");

        // Handle {ng} and {tlh} first, to prevent {n}, {t}, and {l} from
        // spuriously being pulled out of these letters.
        ret = ret.replace(/ng/g, "f");
        ret = ret.replace(/tlh/g, "x");

        Object.keys(x2tlh).forEach(function (key) {
            ret = ret.replace(new RegExp(x2tlh[key], "g"), key);
        });

        // Now that all {ng}s have been processed, it's safe for {gh} to be 'g'
        ret = ret.replace(/G/g, "g");
    } else if (id === "pIqaD") {
        Object.keys(x2p).forEach(function (key) {
            ret = ret.replace(new RegExp(x2p[key], "g"), key);
        });
    }

    return ret;
}

function to_pIqaD(xifan: string) {
    "use strict";

    var ret = "";
    var i = 0;
    var c;

    while (i < xifan.length) {
        c = x2p[xifan.charAt(i)];

        if (c) {
            ret += c;
        } else {
            ret += xifan.charAt(i);
        }

        i += 1;
    }

    return ret;
}

/*
 * xifan -> Okrandian (tlhIngan-Hol)
 * @param {string} xifan
 * @return {string} Okrandian tlhIngan Hol
 */
function to_tlhInganHol(xifan: string) {
    "use strict";

    var ret = "";
    var i = 0;
    var c;

    while (i < xifan.length) {
        c = x2tlh[xifan.charAt(i)];

        if (c) {
            ret += c;
        } else {
            ret += xifan.charAt(i);
        }

        i += 1;
    }

    return ret;
}


function transliterate_cli(input: string, id: string, target: string = "xifan") {
    "use strict";

    if (id === "tlhIngan-Hol") {
        input = input.replace(/[‘’]/g, "'")
    }

    var xifan = to_xifan(input, id);
    if (target === "xifan") {
        return xifan;
    } else if (target === "tlhIngan-Hol") {
        return to_tlhInganHol(xifan);
    } else if (target === "pIqaD") {
        return to_pIqaD(xifan);
    } else {
        throw("Unknown target: " + target);
    }

}

function print_help() {
    console.error("Usage: utcli <input> <id> <target>");
    console.error("  <input> is the input string");
    console.error("  <id> is the Klingon representation (tlhIngan-Hol, pIqaD)");
    console.error("  <target> is the target Klingon representation (xifan, tlhIngan-Hol, pIqaD)");
}

function main() {
    try {
        if (process.argv.includes("--help") || process.argv.includes("-h")) {
            print_help();
            process.exit(0);
        } else if (process.argv.length === 5) {
            console.log(`${transliterate_cli(process.argv[2], process.argv[3], process.argv[4])}`);
            process.exit(0);
        } else if (process.argv.length === 4) {
            var id = process.argv[2];
            var target = process.argv[3];
            console.error('Enter text to transliterate: ' + id + ' -> ' + target);
            rl.on('line', (input) => {
                console.log(`${transliterate_cli(input, id, target)}`);
            });
            rl.on('close', () => {
                process.exit(0);
            });
        } else {
            print_help();
            process.exit(1);
        }

    } catch (e) {
        console.error(e);
        process.exit(1);
    }

}

main();
