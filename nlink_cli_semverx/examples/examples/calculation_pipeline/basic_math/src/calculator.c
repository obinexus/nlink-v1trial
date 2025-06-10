#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main(int argc, char *argv[]) {
    printf("[BASIC_MATH] Calculator v1.2.0 (Stable Range)\n");
    
    if (argc >= 4) {
        double a = atof(argv[2]);
        double b = atof(argv[3]);
        double result = 0;
        
        if (strcmp(argv[1], "add") == 0) result = a + b;
        else if (strcmp(argv[1], "subtract") == 0) result = a - b;
        else if (strcmp(argv[1], "multiply") == 0) result = a * b;
        else if (strcmp(argv[1], "divide") == 0) result = (b != 0) ? a / b : 0;
        
        printf("[RESULT] %.6f\n", result);
        return 0;
    }
    
    if (argc >= 2 && strcmp(argv[1], "--metadata") == 0) {
        printf("[METADATA] Component: basic_math_calculator\n");
        printf("[METADATA] Range State: stable\n");
        printf("[METADATA] Hot-Swap: enabled\n");
        return 0;
    }
    
    printf("Usage: %s <operation> <num1> <num2>\n", argv[0]);
    printf("       %s --metadata\n", argv[0]);
    return 1;
}
