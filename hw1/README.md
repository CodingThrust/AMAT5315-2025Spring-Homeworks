# Homework 1

## Task 1: Get the CPU information of a remote server
Complete the following steps:

1. (clone repo) Create a GitHub account and then fork the homework repository: [AMAT5315-2025Spring-Homeworks](https://github.com/CodingThrust/AMAT5315-2025Spring-Homeworks) to your own account. Then clone the forked repository to the machine you are working on.
2. (login to remote server) Login to a remote server with `ssh`, with
   1. Username: `group1`
   2. Password: `1`
   3. Server IP address: `10.100.0.179`
3. (run task) Create a directory with your name in the home directory of the remote server and then change the directory to the created one, e.g. if your name is `Zhong-Yi NI`, then the directory is `zhongyini`.
    ```bash
    mkdir zhongyini
    cd zhongyini
    ```
    Then run the following commands:
    ```bash
    lscpu > lscpu.txt  # get the CPU information and save it to the file
    date >> lscpu.txt  # add the current date and time to the file
    cat lscpu.txt  # check the content of this file
    ```
4. (download file) Now switch to your local machine and copy the `lscpu.txt` file (at the remote server) to the cloned git repository using `scp`:
    ```bash
    mkdir path/to/your/local/repo/hw1/zhongyini/  # change to your own name
    scp username@server:lscpu.txt path/to/your/local/repo/hw1/zhongyini/
    ```
5. (submit homework)
   1. Create a new branch, following the naming convention `zhongyini/hw1`
   2. `add`, `commit`, and `push` the change to the remote repository.
   3. Submit your homework by creating a pull request (PR) to the original repository.
6. (get feedback) Please check your email for the feedback from the instructor or the TA. Once the feedback is received, please update your homework and submit it again. Your homework will be graded after the PR is merged.
