import java.util.concurrent.atomic.AtomicIntegerArray;

class BetterSafeState implements State {
    private AtomicIntegerArray value;
    private byte maxval;

    BetterSafeState(byte[] v) {
        int[] arr = new int[v.length];
        for (int i = 0; i < v.length; i++) {
            arr[i] = v[i];
        }
        value = new AtomicIntegerArray(arr);
        maxval = 127;
    }

    BetterSafeState(byte[] v, byte m) {
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
        int ival;
        do{
            ival = value.getAcquire(i);
            if(ival <= 0){
                return false;
            }
        } while(!value.compareAndSet(i, ival, ival - 1));
        int jval;
        do{
            jval = value.getAcquire(j);
            if(jval >= maxval){
                do{
                    ival = value.getAcquire(i);
                    if(ival <= 0){
                        return false;
                    }
                } while(!value.compareAndSet(i, ival, ival + 1));
                return false;
            }
        } while(!value.compareAndSet(j, jval, jval + 1));
        return true;
    }
}
