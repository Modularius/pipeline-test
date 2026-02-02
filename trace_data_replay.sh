. ./Libs/replay.sh

#run_repeat_with_ef "test01" "fixed-threshold-discriminator" "--threshold=2100" "--duration=1" "--cool-off=1" " "
#run_repeat_with_ef "test02" "fixed-threshold-discriminator" "--threshold=2200" "--duration=1" "--cool-off=1" " "
#run_repeat_with_ef "test03" "fixed-threshold-discriminator" "--threshold=2200" "--duration=5" "--cool-off=5" " "
#run_repeat_with_ef "test04" "differential-threshold-discriminator" "--threshold=25" "--duration=1" "--cool-off=1" "--constant-multiple=2.0"
#run_repeat_with_ef "test05" "differential-threshold-discriminator" "--threshold=25" "--duration=5" "--cool-off=5" "--constant-multiple=2.0"
#run_repeat_with_ef "test06" "fixed-threshold-discriminator" "--threshold=2200" "--duration=3" "--cool-off=3" " "
#run_repeat_with_ef "test07" "differential-threshold-discriminator" "--threshold=25" "--duration=3" "--cool-off=3" "--constant-multiple=2.0"
#run_repeat_with_ef "test08" "fixed-threshold-discriminator" "--threshold=2100" "--duration=1" "--cool-off=1" " "
#run_repeat_with_ef "test09" "fixed-threshold-discriminator" "--threshold=2100" "--duration=1" "--cool-off=0" " "
#run_repeat_with_ef "test10" "differential-threshold-discriminator" "--threshold=25" "--duration=1" "--cool-off=0" "--central-fin-diff-radius=2"
run_repeat_with_ef "test" "fixed-threshold-discriminator" "--threshold=2100" "--duration=1" "--cool-off=1" " "