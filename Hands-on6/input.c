int main() {
    int x;
    float y;
    char c;
    
    x = 10;
    y = 3.14;
    c = 'A';
    
    if (x > 5) {
        y = y + 1.0;
    }
    
    return 0;
}

int factorial(int n) {
    if (n <= 1) {
        return 1;
    }
    return n * factorial(n - 1);
}
