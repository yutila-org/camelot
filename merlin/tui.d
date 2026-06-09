module merlin.tui;

import std.stdio;
import std.string;
import std.array;
import std.regex;
import std.utf : count;
import std.conv : to;

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

void printLine(string text, int visibleLenOverride = 0) {
    int visibleLen = visibleLenOverride;
    if (visibleLen == 0) {
        auto ansiRegex = regex("\x1b\\[[0-9;]*[a-zA-Z]");
        string cleanText = text.replaceAll(ansiRegex, "");
        visibleLen = cast(int)cleanText.count;
    }
    int pad = 70 - visibleLen;
    string spaces = pad > 0 ? " ".replicate(pad) : "";
    writefln("%s┃%s %s%s %s┃%s", C_BOLD ~ C_MAGENTA, C_RESET, text, spaces, C_BOLD ~ C_MAGENTA, C_RESET);
}

void drawDashboard(string face, string quote, string starLine, int starLineVisualLen, 
                   int quoteVisualLen, bool release, int srcCount, int headerCount, 
                   int testCount, string compilerVersion, string targetName) {
    write("\033[H\033[2J");
    writefln("%s┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓%s", 
             C_BOLD ~ C_MAGENTA, C_RESET);

    printLine(starLine, starLineVisualLen);
    printLine("         " ~ C_MAGENTA ~ "/ \\" ~ C_RESET, 12);
    printLine("       " ~ C_MAGENTA ~ "/_____\\" ~ C_RESET ~ "    " ~ C_WHITE ~ "*   " ~ 
              C_CYAN ~ "M E R L I N   " ~ C_PURPLE ~ "B U I L D   " ~ C_ORANGE ~ 
              "S Y S T E M   " ~ C_YELLOW ~ "v1.0   " ~ C_WHITE ~ "*", 70);
    printLine("       " ~ C_MAGENTA ~ face ~ C_RESET ~ "  " ~ C_CYAN ~ "<" ~ 
              C_WHITE ~ "  \"" ~ C_YELLOW ~ quote ~ C_WHITE ~ "\"", quoteVisualLen);

    writefln("%s┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫%s", 
             C_BOLD ~ C_MAGENTA, C_RESET);

    string profileName = release ? "RELEASE (Optimized, Hardened)" : "DEBUG (Sanitized)";
    printLine("  " ~ C_BOLD ~ C_WHITE ~ "Compiler" ~ C_RESET ~ " : " ~ C_CYAN ~ "clang (v" ~ 
              compilerVersion ~ ")" ~ C_RESET ~ "               " ~ C_BOLD ~ C_WHITE ~ 
              "Profile" ~ C_RESET ~ " : " ~ C_GREEN ~ profileName ~ C_RESET);
    printLine("  " ~ C_BOLD ~ C_WHITE ~ "Standard" ~ C_RESET ~ " : " ~ C_CYAN ~ 
              "C23 (-std=c23)" ~ C_RESET ~ "                   " ~ C_BOLD ~ C_WHITE ~ 
              "Target" ~ C_RESET ~ "  : " ~ C_YELLOW ~ targetName ~ C_RESET);
    printLine("  " ~ C_BOLD ~ C_WHITE ~ "Sources" ~ C_RESET ~ "  : " ~ C_WHITE ~ 
              srcCount.to!string ~ C_RESET ~ "      " ~ C_BOLD ~ C_WHITE ~ "Headers" ~ 
              C_RESET ~ " : " ~ C_WHITE ~ headerCount.to!string ~ C_RESET ~ "          " ~ 
              C_BOLD ~ C_WHITE ~ "Tests" ~ C_RESET ~ "   : " ~ C_WHITE ~ 
              testCount.to!string ~ C_RESET);

    writefln("%s┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫%s", 
             C_BOLD ~ C_MAGENTA, C_RESET);

    printLine("  " ~ C_GREEN ~ "make all" ~ C_RESET ~ "   " ~ C_WHITE ~ "Compile framework" ~ 
              C_RESET ~ "          " ~ C_GREEN ~ "make test" ~ C_RESET ~ "  " ~ C_WHITE ~ 
              "Run tests (ASan)" ~ C_RESET);
    printLine("  " ~ C_GREEN ~ "make run" ~ C_RESET ~ "   " ~ C_WHITE ~ "Launch executable" ~ 
              C_RESET ~ "          " ~ C_GREEN ~ "make clean" ~ C_RESET ~ " " ~ C_WHITE ~ 
              "Clean workspace" ~ C_RESET);

    writefln("%s┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛%s", 
             C_BOLD ~ C_MAGENTA, C_RESET);
    stdout.flush();
}
