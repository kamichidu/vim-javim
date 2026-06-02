package test.classes;

public class MathTest {
    public static void main(String[] args) {
        int a = 10;
        int b = 20;
        int c = a + b;
        int d = c - 5;
        int e = d * 2;
        int f = e / 10;
        System.out.println(f); // Expected: 5

        int sum = 0;
        for (int i = 1; i <= 5; i++) {
            sum += i;
        }
        System.out.println(sum); // Expected: 15
    }
}
