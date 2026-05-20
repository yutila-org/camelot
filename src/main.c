#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define C_RESET   "\033[0m"
#define C_MAGENTA "\033[38;5;198m"
#define C_CYAN    "\033[38;5;81m"
#define C_YELLOW  "\033[38;5;220m"
#define C_WHITE   "\033[37m"

static const char* PHRASES[] = {
    "Welcome to the Round Table, young wizard!",
    "Alakazam! Your C23 program is alive!",
    "I've successfully conjured this execution!",
    "Zero-latency wizardry at your service!",
    "Spellbook successfully loaded!",
    "My magic crystal shows no runtime errors ahead!"
};
#define PHRASES_COUNT (sizeof(PHRASES) / sizeof(PHRASES[0]))

int main(void) {
    srand((unsigned int)time(NULL));
    const char* phrase = PHRASES[rand() % PHRASES_COUNT];

    printf("          %s.%s\n", C_MAGENTA, C_RESET);
    printf("         %s/ \\%s\n", C_MAGENTA, C_RESET);
    printf("       %s/_____\\%s\n", C_MAGENTA, C_RESET);
    printf("       %s( •⩊• )%s  %s<%s  \"%s%s%s\"\n", C_MAGENTA, C_RESET, C_CYAN, C_WHITE, C_YELLOW, phrase, C_WHITE);

    return 0;
}
