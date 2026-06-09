#include <stdio.h>

void test_memory();
void test_slice_and_string();
void test_ds();
void test_io();
void test_pipeline();

int main(void) {
    printf("[RUN] Starting Memory Tests...\n");
    test_memory();
    
    printf("[RUN] Starting Slice & String Tests...\n");
    test_slice_and_string();
    
    printf("[RUN] Starting Data Structure Tests...\n");
    test_ds();
    
    printf("[RUN] Starting I/O Tests...\n");
    test_io();
    
    printf("[RUN] Starting Integration Pipeline...\n");
    test_pipeline();
    
    printf("\nAll Camelot tests passed successfully.\n");
    return 0;
}
