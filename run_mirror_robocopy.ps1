# This file contains the source and target directory paths in a CSV format.
$CSV_PATH_LIST = '.\path_list.csv'

# The robocopy directory
$ROBOCOPY_LOG_DIR = '.\logs'

.\Mirror-Robocopy.ps1 -robocopy_log_dir $ROBOCOPY_LOG_DIR -csv_dir_list_file $CSV_PATH_LIST
