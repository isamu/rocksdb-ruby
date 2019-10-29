echo "---- mmkf.log ----"
cat ext/rocksdb/mkmf.log
echo "---- makefile ----"
cat ext/rocksdb/Makefile

if [ $TRAVIS_OS_NAME = 'linux' ]; then
  # Show core dump contents and build configuration if any
 COREFILE=$(find . -maxdepth 1 -name "core*" | head -n 1)
 CORE_PROG=$(which ruby)
 echo "---- gdb $CORE_PROG -c "$COREFILE" ----"
 if [[ -f "$COREFILE" ]]; then
   gdb $CORE_PROG -c "$COREFILE" -ex "thread apply all bt full" -ex "set pagination 0" -batch
fi
else
  echo "Can't inspect coredump on ${TRAVIS_OS_NAME}"
fi
