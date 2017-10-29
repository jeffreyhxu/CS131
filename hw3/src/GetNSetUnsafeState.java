import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSetUnsafeState implements State {
    private AtomicIntegerArray value;
    private byte maxval;
    private boolean delay = false;

    GetNSetUnsafeState(byte[] v) {
        int[] arr = new int[v.length];
        for (int i = 0; i < v.length; i++) {
            arr[i] = v[i];
        }
        value = new AtomicIntegerArray(arr);
        maxval = 127;
    }

    GetNSetUnsafeState(byte[] v, byte m) {
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
        delay ^= true;
        int ival = value.get(i), jval = value.get(j);
        if (ival <= 0 || jval >= maxval) {
            return false;
        }
        value.set(i, ival - 1);
        if(delay){
            for(int k = 0; k < 100; k++){
                System.out.print("");
            }
        }
        value.set(j, jval + 1);
        return true;
    }
}
