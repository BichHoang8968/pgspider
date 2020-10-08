#for dynahash_thread.c
grep -RoPh "(?<=hash_create\().+?\"(?=)|(?<=ShmemInitHash\().+?\"(?=)" |grep -v "fdw" | grep -v "Shippability cache" | sort -f | uniq | awk '{print $0,","}' | sort -f
