import java.util.concurrent.locks.*;

public class BetterSafe3State implements State{
    private byte[] value;
    private byte maxval;
    private ReentrantLock[] locks;

    BetterSafe3State(byte[] v) {
        value = v;
        maxval = 127;
        locks = new ReentrantLock[value.length];
        for(int i = 0; i < value.length; i++){
            locks[i] = new ReentrantLock();
        }
    }

    BetterSafe3State(byte[] v, byte m) {
        value = v;
        maxval = m;
        locks = new ReentrantLock[value.length];
        for(int i = 0; i < value.length; i++){
            locks[i] = new ReentrantLock();
        }
    }

    public int size() { return value.length; }

    public byte[] current() { return value; }

    public boolean swap(int i, int j) {
        locks[Math.max(i, j)].lock();
        locks[Math.min(i, j)].lock();
        try{
            if(value[i] <= 0 || value[j] >= maxval){
                return false;
            }
            value[i]--;
            value[j]++;
            return true;
        } finally {
            locks[Math.min(i, j)].unlock();
            locks[Math.max(i, j)].unlock();
        }
    }
}
