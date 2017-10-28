import java.util.concurrent.atomic.AtomicIntegerArray;

class BetterSafe2State implements State {
    private AtomicIntegerArray value;
    private byte maxval;

    BetterSafe2State(byte[] v) {
        int[] arr = new int[v.length];
        for (int i = 0; i < v.length; i++) {
            arr[i] = v[i];
        }
        value = new AtomicIntegerArray(arr);
        maxval = 127;
    }

    BetterSafe2State(byte[] v, byte m) {
        int[] arr = new int[v.length];
        for (int i = 0; i < v.length; i++) {
            arr[i] = v[i];
        }
        value = new AtomicIntegerArray(arr);
        maxval = m;
    }

    public int size() { return value.length(); }

    public byte[] current() {
        byte[] ans = new byte[value.length()];
        for (int i = 0; i < ans.length; i++) {
            ans[i] = (byte) (value.getAcquire(i) & 0xFF);
        }
        return ans;
    }

    public synchronized boolean swap(int i, int j) {
        if (value.get(i) <= 0 || value.get(j) >= maxval) {
            return false;
        }
        int ival = value.get(i);
        if (!value.compareAndSet(i, ival, ival - 1)) {
            return false;
        }
        int jval = value.get(j);
        if (value.compareAndSet(j, jval, jval + 1)) {
            return true;
        }
        do {
            ival = value.get(i);
        } while (!value.compareAndSet(i, ival, ival + 1)); // j failed, so undo i
        return false;
    }
}
