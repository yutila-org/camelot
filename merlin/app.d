module merlin.app;

import std.stdio;
import std.string;
import std.file;
import std.process;
import std.path;
import std.random;
import std.algorithm;
import std.utf : count;
import core.thread : Thread;
import core.time : msecs;

import merlin.tui;
import merlin.builder;

void main(string[] args) {
    bool release = false;
    foreach (arg; args) {
        if (arg == "RELEASE=1") release = true;
    }

    if (args.length > 1) {
        string cmd = args[1];
        if (cmd == "all") {
            if (release) {
                writefln("\033[1;36m[PRE-FLIGHT] Running mandatory sanitized test suite before Release build...\033[0m");
                runTests(false);
                writefln("\033[1;36m[PRE-FLIGHT SUCCESS] Tests passed! Proceeding with optimized Release build...\033[0m\n");
            }
            buildTarget(release, false);
            writefln("\n\033[1;32m[BUILD SUCCESS] Target compiled and linked successfully.\033[0m\n");
        } else if (cmd == "test") {
            runTests(release);
        } else if (cmd == "run") {
            runTarget(release);
        } else if (cmd == "clean") {
            cleanAll();
        } else if (cmd == "init") {
            string projName = args.length > 2 ? args[2] : baseName(getcwd());
            initProject(".", projName);
        } else if (cmd == "new") {
            if (args.length < 3) {
                writefln("\033[1;31m[ERROR] Please specify a project name. (e.g., merlin new my_app)\033[0m");
                return;
            }
            initProject(args[2], args[2]);
        } else {
            writefln("Unknown target: %s", cmd);
        }
        return;
    }

    // Fetch dynamic project metrics (highly portable scanning!)
    int srcCount = 0;
    int headerCount = 0;
    int testCount = 0;

    if (exists("src") && isDir("src")) {
        srcCount = countFiles("src", ".c");
    } else {
        foreach (DirEntry entry; dirEntries(".", SpanMode.depth)) {
            string base = baseName(entry.name);
            if (entry.name.canFind("/obj/") || entry.name.canFind("/bin/") || base.startsWith(".")) continue;
            if (entry.isFile && entry.name.endsWith(".c") && !entry.name.canFind("test")) srcCount++;
        }
    }

    if (exists("include") && isDir("include")) {
        headerCount = countFiles("include", ".h");
    } else {
        foreach (DirEntry entry; dirEntries(".", SpanMode.depth)) {
            string base = baseName(entry.name);
            if (entry.name.canFind("/obj/") || entry.name.canFind("/bin/") || base.startsWith(".")) continue;
            if (entry.isFile && entry.name.endsWith(".h")) headerCount++;
        }
    }

    if (exists("tests") && isDir("tests")) {
        testCount = countFiles("tests", ".c");
    } else {
        foreach (DirEntry entry; dirEntries(".", SpanMode.depth)) {
            string base = baseName(entry.name);
            if (entry.name.canFind("/obj/") || entry.name.canFind("/bin/") || base.startsWith(".")) continue;
            if (entry.isFile && entry.name.endsWith(".c") && entry.name.canFind("test")) testCount++;
        }
    }

    string targetName = baseName(getcwd());
    string compilerVersion = "Unknown";
    try {
        auto res = executeShell("clang -dumpversion");
        if (res.status == 0) compilerVersion = res.output.strip();
    } catch (Exception e) {}

    // Dynamic Entrance Twinkle Animation within the SAME unified box!
    drawDashboard("( -⩊- )", "Summoning build portal...", 
        "          " ~ C_YELLOW ~ "+" ~ C_RESET, 11, 21 + 25, release, srcCount, 
        headerCount, testCount, compilerVersion, targetName);
    Thread.sleep(180.msecs);

    drawDashboard("( •⩊• )", "Focusing mana energy...", 
        "       " ~ C_YELLOW ~ "*  " ~ C_MAGENTA ~ "." ~ C_YELLOW ~ "  *" ~ C_RESET, 
        15, 21 + 24, release, srcCount, headerCount, testCount, compilerVersion, targetName);
    Thread.sleep(180.msecs);

    drawDashboard("( ๑>⩊<๑ )", "Alakazam! Welcome back!", 
        "       " ~ C_YELLOW ~ "✦  " ~ C_MAGENTA ~ "." ~ C_YELLOW ~ "  ✦" ~ C_RESET, 
        15, 23 + 23, release, srcCount, headerCount, testCount, compilerVersion, targetName);
    Thread.sleep(220.msecs);

    // Final static frame draw with random quote
    string[] quotes = [
        "Poof! Let's cast some build spells!",
        "Did someone say... MAGIC?!",
        "C23 is my favorite magic circle!",
        "Stay hydrated, young wizard!",
        "Workin' my magic on your code!",
        "Abracadabra! What are we building?",
        "Ready to conjure some binaries!",
        "No bugs can escape my spellbook!"
    ];
    string randomQuote = quotes[uniform(0, quotes.length)];
    drawDashboard("( •⩊• )", randomQuote, 
        "          " ~ C_MAGENTA ~ "." ~ C_RESET, 11, 21 + cast(int)randomQuote.count, 
        release, srcCount, headerCount, testCount, compilerVersion, targetName);

    // Interactive magical command shell!
    while (true) {
        writef("\n\033[1;38;5;198m🔮 Merlin\033[0m > ");
        stdout.flush();

        string line = readln();
        if (line is null) {
            break;
        }
        string input = line.strip().toLower();
        if (input == "exit" || input == "quit" || input == "5" || input == "q") {
            writefln("\n\033[1;38;5;198m( ๑◡⩊◡๑ )\033[0m " ~
                "\033[33m< \"Farewell, young wizard! May your spells stay sharp.\"\033[0m\n");
            break;
        }

        if (input == "all" || input == "build" || input == "1") {
            if (release) {
                writefln("\033[1;36m[PRE-FLIGHT] Running mandatory sanitized test suite before Release build...\033[0m");
                runTests(false);
                writefln("\033[1;36m[PRE-FLIGHT SUCCESS] Tests passed! Proceeding with optimized Release build...\033[0m\n");
            }
            buildTarget(release, false);
            writefln("\n\033[1;32m[BUILD SUCCESS] Target compiled and linked successfully.\033[0m\n");
        } else if (input == "test" || input == "2") {
            runTests(release);
        } else if (input == "run" || input == "3") {
            runTarget(release);
        } else if (input == "clean" || input == "4") {
            cleanAll();
            srcCount = 0;
            headerCount = 0;
            testCount = 0;
        } else if (input.startsWith("init")) {
            string[] parts = input.split(" ");
            string projName = parts.length > 1 ? parts[1] : baseName(getcwd());
            initProject(".", projName);
        } else if (input.startsWith("new")) {
            string[] parts = input.split(" ");
            if (parts.length < 2) {
                writefln("\033[1;31m[ERROR] Please specify a project name. (e.g., new my_app)\033[0m");
            } else {
                initProject(parts[1], parts[1]);
            }
        } else if (input == "help" || input == "dashboard" || input == "h" || input == "") {
            // Re-scan dynamic stats in case files were added or removed
            srcCount = 0;
            headerCount = 0;
            testCount = 0;
            if (exists("src") && isDir("src")) {
                srcCount = countFiles("src", ".c");
            } else {
                foreach (DirEntry entry; dirEntries(".", SpanMode.depth)) {
                    string base = baseName(entry.name);
                    if (entry.name.canFind("/obj/") || entry.name.canFind("/bin/") || base.startsWith(".")) continue;
                    if (entry.isFile && entry.name.endsWith(".c") && !entry.name.canFind("test")) srcCount++;
                }
            }
            if (exists("include") && isDir("include")) {
                headerCount = countFiles("include", ".h");
            } else {
                foreach (DirEntry entry; dirEntries(".", SpanMode.depth)) {
                    string base = baseName(entry.name);
                    if (entry.name.canFind("/obj/") || entry.name.canFind("/bin/") || base.startsWith(".")) continue;
                    if (entry.isFile && entry.name.endsWith(".h")) headerCount++;
                }
            }
            if (exists("tests") && isDir("tests")) {
                testCount = countFiles("tests", ".c");
            } else {
                foreach (DirEntry entry; dirEntries(".", SpanMode.depth)) {
                    string base = baseName(entry.name);
                    if (entry.name.canFind("/obj/") || entry.name.canFind("/bin/") || base.startsWith(".")) continue;
                    if (entry.isFile && entry.name.endsWith(".c") && entry.name.canFind("test")) testCount++;
                }
            }
            randomQuote = quotes[uniform(0, quotes.length)];
            drawDashboard("( •⩊• )", randomQuote, 
                "          " ~ C_MAGENTA ~ "." ~ C_RESET, 11, 21 + cast(int)randomQuote.count, 
                release, srcCount, headerCount, testCount, compilerVersion, targetName);
        } else {
            writefln("\033[1;31mUnknown spell: \"%s\". (Spells: all, test, run, clean, init, new, help, exit)\033[0m", input);
        }
    }
}
