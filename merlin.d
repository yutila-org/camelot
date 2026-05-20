import std.stdio;
import core.stdc.stdlib;
import std.string;
import std.array;
import std.file;
import std.process;
import std.path;
import std.random;
import std.algorithm;
import std.regex;
import std.utf : count;
import std.conv;
import core.thread : Thread;
import core.time : msecs;

// Curated colors
const string C_RESET   = "\033[0m";
const string C_BOLD    = "\033[1m";
const string C_RED     = "\033[31m";
const string C_GREEN   = "\033[32m";
const string C_YELLOW  = "\033[33m";
const string C_BLUE    = "\033[34m";
const string C_MAGENTA = "\033[38;5;198m";
const string C_CYAN    = "\033[38;5;81m";
const string C_WHITE   = "\033[37m";
const string C_PURPLE  = "\033[38;5;141m";
const string C_ORANGE  = "\033[38;5;208m";

// UTF-8 code point length counting print wrapper
void printLine(string text, int visibleLenOverride = 0) {
    int visibleLen = visibleLenOverride;
    if (visibleLen == 0) {
        // Strip ANSI escape codes
        auto ansiRegex = regex("\x1b\\[[0-9;]*[a-zA-Z]");
        string cleanText = text.replaceAll(ansiRegex, "");
        visibleLen = cast(int)cleanText.count;
    }
    int pad = 70 - visibleLen;
    string spaces = pad > 0 ? " ".replicate(pad) : "";
    writefln("%s┃%s %s%s %s┃%s", C_BOLD ~ C_MAGENTA, C_RESET, text, spaces, C_BOLD ~ C_MAGENTA, C_RESET);
}

// Unified single-box drawing engine (prevents stray bars and layout shifting!)
void drawDashboard(string face, string quote, string starLine, int starLineVisualLen, int quoteVisualLen, bool release, int srcCount, int headerCount, int testCount, string compilerVersion, string targetName) {
    write("\033[H\033[2J");
    writefln("%s┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓%s", C_BOLD ~ C_MAGENTA, C_RESET);

    printLine(starLine, starLineVisualLen);
    printLine("         " ~ C_MAGENTA ~ "/ \\" ~ C_RESET, 12);
    printLine("       " ~ C_MAGENTA ~ "/_____\\" ~ C_RESET ~ "    " ~ C_WHITE ~ "*   " ~ C_CYAN ~ "M E R L I N   " ~ C_PURPLE ~ "B U I L D   " ~ C_ORANGE ~ "S Y S T E M   " ~ C_YELLOW ~ "v1.0   " ~ C_WHITE ~ "*", 70);
    printLine("       " ~ C_MAGENTA ~ face ~ C_RESET ~ "  " ~ C_CYAN ~ "<" ~ C_WHITE ~ "  \"" ~ C_YELLOW ~ quote ~ C_WHITE ~ "\"", quoteVisualLen);

    writefln("%s┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫%s", C_BOLD ~ C_MAGENTA, C_RESET);

    string profileName = release ? "RELEASE (Optimized, Hardened)" : "DEBUG (Sanitized)";
    printLine("  " ~ C_BOLD ~ C_WHITE ~ "Compiler" ~ C_RESET ~ " : " ~ C_CYAN ~ "gcc (v" ~ compilerVersion ~ ")" ~ C_RESET ~ "               " ~ C_BOLD ~ C_WHITE ~ "Profile" ~ C_RESET ~ " : " ~ C_GREEN ~ profileName ~ C_RESET);
    printLine("  " ~ C_BOLD ~ C_WHITE ~ "Standard" ~ C_RESET ~ " : " ~ C_CYAN ~ "C23 (-std=c23)" ~ C_RESET ~ "                   " ~ C_BOLD ~ C_WHITE ~ "Target" ~ C_RESET ~ "  : " ~ C_YELLOW ~ targetName ~ C_RESET);
    printLine("  " ~ C_BOLD ~ C_WHITE ~ "Sources" ~ C_RESET ~ "  : " ~ C_WHITE ~ srcCount.to!string ~ C_RESET ~ "      " ~ C_BOLD ~ C_WHITE ~ "Headers" ~ C_RESET ~ " : " ~ C_WHITE ~ headerCount.to!string ~ C_RESET ~ "          " ~ C_BOLD ~ C_WHITE ~ "Tests" ~ C_RESET ~ "   : " ~ C_WHITE ~ testCount.to!string ~ C_RESET);

    writefln("%s┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫%s", C_BOLD ~ C_MAGENTA, C_RESET);

    printLine("  " ~ C_GREEN ~ "make all" ~ C_RESET ~ "   " ~ C_WHITE ~ "Compile framework" ~ C_RESET ~ "          " ~ C_GREEN ~ "make test" ~ C_RESET ~ "  " ~ C_WHITE ~ "Run tests (ASan)" ~ C_RESET);
    printLine("  " ~ C_GREEN ~ "make run" ~ C_RESET ~ "   " ~ C_WHITE ~ "Launch executable" ~ C_RESET ~ "          " ~ C_GREEN ~ "make clean" ~ C_RESET ~ " " ~ C_WHITE ~ "Clean workspace" ~ C_RESET);

    writefln("%s┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛%s", C_BOLD ~ C_MAGENTA, C_RESET);
    stdout.flush();
}

int countFiles(string dirPath, string extension) {
    if (!exists(dirPath) || !isDir(dirPath)) return 0;
    int count = 0;
    foreach (DirEntry entry; dirEntries(dirPath, SpanMode.depth)) {
        if (entry.isFile && entry.name.endsWith(extension)) {
            count++;
        }
    }
    return count;
}

void buildTarget(bool release, bool testTarget) {
    string objDir = release ? "obj/release" : "obj/debug";
    mkdirRecurse(objDir);
    mkdirRecurse("bin");

    // Detect C23 standard support flag (fallback to C2x on older compilers)
    string stdFlag = "-std=c23";
    try {
        auto res = executeShell("gcc -std=c23 -E - < /dev/null");
        if (res.status != 0) {
            stdFlag = "-std=c2x";
        }
    } catch (Exception e) {
        stdFlag = "-std=c2x";
    }

    // GCC build orchestration with full Yutila Security mitigation compliance
    string[] cflags = ["-Wall", "-Wextra", "-Wpedantic", "-Werror", stdFlag, "-Iinclude", "-fPIE", "-fstack-protector-strong"];
    string[] ldflags = ["-pie", "-Wl,-z,noexecstack"];

    if (release) {
        cflags ~= ["-O2", "-fwrapv", "-fno-delete-null-pointer-checks", "-fno-strict-overflow", "-D_FORTIFY_SOURCE=2"];
    } else {
        cflags ~= ["-O0", "-g", "-fsanitize=address,undefined,leak", "-ftrapv"];
        ldflags ~= ["-fsanitize=address,undefined,leak"];
    }

    // Dynamic recursive scanning of project files (strictly portable targets!)
    string[] srcFiles;
    if (exists("src") && isDir("src")) {
        foreach (DirEntry entry; dirEntries("src", SpanMode.depth)) {
            if (entry.isFile && entry.name.endsWith(".c")) {
                srcFiles ~= entry.name;
            }
        }
    } else {
        foreach (DirEntry entry; dirEntries(".", SpanMode.depth)) {
            string base = baseName(entry.name);
            if (entry.name.canFind("/obj/") || entry.name.canFind("/bin/") || base.startsWith(".")) continue;
            if (entry.isFile && entry.name.endsWith(".c") && !entry.name.canFind("test")) {
                srcFiles ~= entry.name;
            }
        }
    }

    // Dynamic entry point detection (excludes int main during testing passes)
    string mainSrcFile = "";
    foreach (src; srcFiles) {
        try {
            if (readText(src).canFind("int main")) {
                mainSrcFile = src;
            }
        } catch (Exception e) {}
    }

    string[] objFiles;
    foreach (src; srcFiles) {
        if (testTarget && src == mainSrcFile) continue;

        string relPath = exists("src") ? src["src/".length .. $] : baseName(src);
        string objPath = buildPath(objDir, relPath.setExtension(".o"));
        mkdirRecurse(dirName(objPath));

        writef("\033[1;36m> Compiler:\033[0m Compiling \033[2m%s\033[0m -> %s...\n", src, objPath);
        stdout.flush();

        auto cmd = ["gcc"] ~ cflags ~ ["-c", src, "-o", objPath];
        auto pid = spawnProcess(cmd);
        if (wait(pid) != 0) {
            writefln("\n\033[1;38;5;198m( ๑✖⩊✖๑ )\033[0m \033[31m< \"Spell backfired on %s! Check errors above.\"\033[0m\n", src);
            exit(1);
        }
        objFiles ~= objPath;
    }

    if (testTarget) {
        string[] testSrcs;
        if (exists("tests") && isDir("tests")) {
            foreach (DirEntry entry; dirEntries("tests", SpanMode.depth)) {
                if (entry.isFile && entry.name.endsWith(".c")) {
                    testSrcs ~= entry.name;
                }
            }
        } else {
            foreach (DirEntry entry; dirEntries(".", SpanMode.depth)) {
                string base = baseName(entry.name);
                if (entry.name.canFind("/obj/") || entry.name.canFind("/bin/") || base.startsWith(".")) continue;
                if (entry.isFile && entry.name.endsWith(".c") && entry.name.canFind("test")) {
                    testSrcs ~= entry.name;
                }
            }
        }

        foreach (src; testSrcs) {
            string relPath = exists("tests") ? src["tests/".length .. $] : baseName(src);
            string objPath = buildPath(objDir, "tests", relPath.setExtension(".o"));
            mkdirRecurse(dirName(objPath));

            writef("\033[1;36m> Compiler:\033[0m Compiling \033[2m%s\033[0m -> %s...\n", src, objPath);
            stdout.flush();

            auto cmd = ["gcc"] ~ cflags ~ ["-c", src, "-o", objPath];
            auto pid = spawnProcess(cmd);
            if (wait(pid) != 0) {
                writefln("\n\033[1;38;5;198m( ๑✖⩊✖๑ )\033[0m \033[31m< \"Spell backfired on test source %s!\"\033[0m\n", src);
                exit(1);
            }
            objFiles ~= objPath;
        }

        string testBin = buildPath("bin", "test_" ~ baseName(getcwd()));
        writefln("\033[1;34m[BUILD] Linker:\033[0m Linking test runner %s...", testBin);
        stdout.flush();

        auto cmd = ["gcc"] ~ objFiles ~ ["-o", testBin] ~ ldflags;
        auto pid = spawnProcess(cmd);
        if (wait(pid) != 0) {
            writefln("\n\033[1;38;5;198m( ๑✖⩊✖๑ )\033[0m \033[31m< \"Oh no! Test linking spell backfired!\"\033[0m\n");
            exit(1);
        }
    } else {
        string binPath = buildPath("bin", baseName(getcwd()));
        writefln("\033[1;34m[BUILD] Linker:\033[0m Generating %s...", binPath);
        stdout.flush();

        auto cmd = ["gcc"] ~ objFiles ~ ["-o", binPath] ~ ldflags;
        auto pid = spawnProcess(cmd);
        if (wait(pid) != 0) {
            writefln("\n\033[1;38;5;198m( ๑✖⩊✖๑ )\033[0m \033[31m< \"Oh no! Linker spell backfired!\"\033[0m\n");
            exit(1);
        }
    }
}

void cleanAll() {
    writefln("\033[1;38;5;198m( ๑◡⩊◡๑ )\033[0m \033[33m< \"Poof! Cleaning all Merlin caches, object files, and binaries!\"\033[0m");
    if (exists("obj")) rmdirRecurse("obj");
    if (exists("bin")) rmdirRecurse("bin");
    writefln("\033[1;38;5;198m( ๑>⩊<๑ )\033[0m \033[32m< \"Workspace is pristine once again!\"\033[0m");
}

void runTests(bool release) {
    buildTarget(release, true);
    string testBin = buildPath("bin", "test_" ~ baseName(getcwd()));
    writefln("\n\033[1;38;5;198m( ๑•̀⩊•́๑ )\033[0m \033[36m< \"Initiating magical sanitizer testing check...\"\033[0m");
    writefln("\033[1;33m[RUN] Executing %s Test Suite...\033[0m\n", baseName(getcwd()));
    stdout.flush();

    auto pid = spawnProcess([testBin]);
    if (wait(pid) != 0) {
        writefln("\n\033[1;38;5;198m( ๑✖⩊✖๑ )\033[0m \033[31m< \"Alas! A sanitizer or test assertion failed! Debug time!\"\033[0m\n");
        exit(1);
    }
    writefln("\n\033[1;38;5;198m( ๑★⩊★๑ )\033[0m \033[32m< \"Fantastic! All tests passed successfully under my wizard watch!\"\033[0m\n");
}

void runTarget(bool release) {
    buildTarget(release, false);
    string binPath = buildPath("bin", baseName(getcwd()));
    writefln("\n\033[1;33m[RUN] Launching %s...\033[0m\n", baseName(getcwd()));
    stdout.flush();
    auto pid = spawnProcess([binPath]);
    wait(pid);
}

void main(string[] args) {
    bool release = false;
    foreach (arg; args) {
        if (arg == "RELEASE=1") release = true;
    }

    if (args.length > 1) {
        string cmd = args[1];
        if (cmd == "all") {
            buildTarget(release, false);
            writefln("\n\033[1;38;5;198m( ๑>⩊<๑ )\033[0m \033[32m< \"Ta-da! Your binary is ready!\"\033[0m\n");
        } else if (cmd == "test") {
            runTests(release);
        } else if (cmd == "run") {
            runTarget(release);
        } else if (cmd == "clean") {
            cleanAll();
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
        auto res = executeShell("gcc -dumpversion");
        if (res.status == 0) compilerVersion = res.output.strip();
    } catch (Exception e) {}

    // Dynamic Entrance Twinkle Animation within the SAME unified box!
    drawDashboard("( -⩊- )", "Summoning build portal...", "          " ~ C_YELLOW ~ "+" ~ C_RESET, 11, 21 + 25, release, srcCount, headerCount, testCount, compilerVersion, targetName);
    Thread.sleep(180.msecs);

    drawDashboard("( •⩊• )", "Focusing mana energy...", "       " ~ C_YELLOW ~ "*  " ~ C_MAGENTA ~ "." ~ C_YELLOW ~ "  *" ~ C_RESET, 15, 21 + 24, release, srcCount, headerCount, testCount, compilerVersion, targetName);
    Thread.sleep(180.msecs);

    drawDashboard("( ๑>⩊<๑ )", "Alakazam! Welcome back!", "       " ~ C_YELLOW ~ "✦  " ~ C_MAGENTA ~ "." ~ C_YELLOW ~ "  ✦" ~ C_RESET, 15, 23 + 23, release, srcCount, headerCount, testCount, compilerVersion, targetName);
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
    drawDashboard("( •⩊• )", randomQuote, "          " ~ C_MAGENTA ~ "." ~ C_RESET, 11, 21 + cast(int)randomQuote.count, release, srcCount, headerCount, testCount, compilerVersion, targetName);

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
            writefln("\n\033[1;38;5;198m( ๑◡⩊◡๑ )\033[0m \033[33m< \"Farewell, young wizard! May your spells stay sharp.\"\033[0m\n");
            break;
        }

        if (input == "all" || input == "build" || input == "1") {
            buildTarget(release, false);
            writefln("\n\033[1;38;5;198m( ๑>⩊<๑ )\033[0m \033[32m< \"Ta-da! Your C framework build is complete!\"\033[0m\n");
        } else if (input == "test" || input == "2") {
            runTests(release);
        } else if (input == "run" || input == "3") {
            runTarget(release);
        } else if (input == "clean" || input == "4") {
            cleanAll();
            srcCount = 0;
            headerCount = 0;
            testCount = 0;
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
            drawDashboard("( •⩊• )", randomQuote, "          " ~ C_MAGENTA ~ "." ~ C_RESET, 11, 21 + cast(int)randomQuote.count, release, srcCount, headerCount, testCount, compilerVersion, targetName);
        } else {
            writefln("\033[1;31mUnknown spell: \"%s\". (Spells: all, test, run, clean, help, exit)\033[0m", input);
        }
    }
}
