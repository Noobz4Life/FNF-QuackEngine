package backend;

import sys.thread.ElasticThreadPool;
import sys.thread.Lock;
import sys.thread.Thread;

class Threader {
    private static final threadPool:ElasticThreadPool = new ElasticThreadPool(4,30);

    private static var threads:Int = 0;
    private static var lock:Lock = new Lock();

    public static function create(job:() -> Void,?important:Bool = false):Void {
        #if (target.threaded)
        if(ClientPrefs.data.multiThreading) {
            if(!important) {
                threadPool.run(function() {
                    job();
                    lock.release();
                });
                threads++;
            } else {
                Thread.create(function() {
                    job();
                    lock.release();
                });
                threads++;
            }
        } else #end job();
    }

    public static function wait() {
        while(threads > 0) {
            trace("Waiting for thread "+threads);
            lock.wait();
            threads--;
        }
    }
}