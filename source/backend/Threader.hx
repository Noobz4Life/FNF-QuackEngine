package backend;

import sys.thread.Lock;
import sys.thread.Thread;

class Threader {
    private static var threads:Int = 0;
    private static var lock:Lock = new Lock();

    public static function create(job:() -> Void):Thread {
        #if (target.threaded)
        if(ClientPrefs.data.multiThreading) {
            var thread = Thread.create(function() {
                job();
                lock.release();
            });
            threads++;
            return thread;
        } else #end job();
        return null;
    }

    public static function wait() {
        while(threads > 0) {
            lock.wait();
            threads--;
        }
    }
}