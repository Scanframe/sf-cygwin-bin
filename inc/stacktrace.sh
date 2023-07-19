
function stacktrace
{
   local i=1 line file func
   while read -r line func file < <(caller $i); do
      echo >&2 "[$i] $file:$line $func(): $(sed -n ${line}p $file)"
      ((i++))
   done
}
