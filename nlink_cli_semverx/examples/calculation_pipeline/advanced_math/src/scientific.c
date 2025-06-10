#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main(int argc, char *argv[]) {
    printf("[ADVANCED_MATH] Scientific Calculator v2.0.0-alpha.1 (Experimental Range)\n");
    
    if (argc >= 3) {
        double a = atof(argv[2]);
        double result = 0;
        
        if (strcmp(argv[1], "sin") == 0) result = sin(a);
        else if (strcmp(argv[1], "cos") == 0) result = cos(a);
        else if (strcmp(argv[1], "log") == 0) result = log(a);
        else if (strcmp(argv[1], "sqrt") == 0) result = sqrt(a);
        
        printf("[RESULT] %.10f\n", result);
        return 0;
    }
    
    printf("Usage: %s <function> <value>\n", argv[0]);
    return 1;
}
