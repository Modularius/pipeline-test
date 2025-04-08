H5DUMP=/nix/store/h9wq1p0zfbsm1k15rdyzm0x939cqgx7m-hdf5-cpp-1.12.2-bin/bin/h5dump

PATH=archive/incoming/local
FILE=${PATH}/test1.nxs

SELOG="Earth\'s\ Core"
SELOGPATH="/raw_data_1/detector_1/event_id[1;1;100;1]"
H5PATH=${SELOGPATH}

$H5DUMP -d ${H5PATH} ${FILE}