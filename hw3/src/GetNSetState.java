import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSetState implements State {
    private AtomicIntegerArray value;
    private byte maxval;

    GetNSetState(byte[] v) {
        int[] arr = new int[v.length];
        for (int i = 0; i < v.length; i++) {
            arr[i] = v[i];
        }
        value = new AtomicIntegerArray(arr);
        maxval = 127;
    }

    GetNSetState(byte[] v, byte m) {
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
            ans[i] = (byte) (value.get(i) & 0xFF);
        }
        return ans;
    }

    public synchronized boolean swap(int i, int j) {
        if (value.get(i) <= 0 || value.get(j) >= maxval) {
            return false;
        }
        value.set(i, value.get(i) - 1);
        value.set(j, value.get(j) + 1);
        return true;
    }
}
