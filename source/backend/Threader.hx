package backend;

import sys.thread.Lock;
import sys.thread.Thread;

class Threader {
    private static var threads:Array<Thread> = [];
    private static var lock:Lock = new Lock();

    public static function create(job:() -> Void):Thread {
        #if (target.threaded)
        if(ClientPrefs.data.multiThreading) {
            var thread = Thread.create(function() {
                job();
                lock.release();
            });
            trace(thread);
            threads.push(thread);
            return thread;
        } else #end job();
        return null;
    }

    public static function wait() {
        trace(threads.length);
        if(threads.length <= 0) return;
        for(_ in threads) {
            lock.wait();
        }
        threads = [];
    }
}