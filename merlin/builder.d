module merlin.builder;

import std.stdio;
import std.file;
import std.process;
import std.path;
import std.algorithm;
import std.string;
import core.stdc.stdlib : exit;

import merlin.tui;

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
