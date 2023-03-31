#!/bin/bash
# bin-splitter-applet 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://documentation.dnanexus.com/developer for tutorials on how
# to modify this file.

main() {

    echo "Value of binary_file_to_split: '$binary_file_to_split'"
    echo "Value of split_size: '$split_size'"
    echo "Value of verbose: '$verbose'"

    FILENAME="$(dx describe "$binary_file_to_split" --name)"
    echo "Filename : ${FILENAME}"

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    dx download "$binary_file_to_split" -o "${FILENAME}"

    # Split the file locally

    #VERBOSE="-v"
    VERBOSE="" # TODO
    # -o is a prefix
    bin_splitter -b "${FILENAME}" -o "${FILENAME}" -n ${split_size} ${VERBOSE}
    splitted_binaries_array=($(ls "${FILENAME}_"*))

    # Upload the splitted files
    for i in "${!splitted_binaries_array[@]}"; do
        splitted_binary_files[$i]=$(dx upload "${splitted_binaries_array[$i]}" --brief)
    done

    # Fill in your application code here.
    #
    # To report any recognized errors in the correct format in
    # $HOME/job_error.json and exit this script, you can use the
    # dx-jobutil-report-error utility as follows:
    #
    #   dx-jobutil-report-error "My error message"
    #
    # Note however that this entire bash script is executed with -e
    # when running in the cloud, so any line which returns a nonzero
    # exit code will prematurely exit the script; if no error was
    # reported in the job_error.json file, then the failure reason
    # will be AppInternalError with a generic error message.

    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    # Validate the output
    for i in "${!splitted_binary_files[@]}"; do
        dx-jobutil-add-output splitted_binary_files "${splitted_binary_files[$i]}" --class=array:file
    done
}
