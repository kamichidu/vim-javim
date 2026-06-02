package test.classes;

public class LoopBenchmark {
    public static int run(int n) {
        int sum = 0;
        for (int i = 0; i < n; i++) {
            sum += i;
        }
        return sum;
    }

    public static void main(String[] args) {
        System.out.println(run(10000));
    }
}
