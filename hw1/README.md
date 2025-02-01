# Homework 1

## Task 1: Get the CPU information of a remote server
Complete the following steps:

1. Create a GitHub account and then fork the homework repository: [AMAT5315-2025Spring-Homeworks](https://github.com/CodingThrust/AMAT5315-2025Spring-Homeworks) to your own account. Then clone the forked repository to the machine you are working on.
2. Login to a remote server with `ssh`, the `username` is your name (lowercase) and the `server` IP address is `10.100.0.179`. Password will be provided in the class.
3. Run the following commands:
    ```bash
    cd AMAT5315-2025Spring-Homeworks/username
    lscpu > lscpu.txt
    cat lscpu.txt  # check the content of this file
    ```
    where `username` is your name (lowercase).
4. Copy the `lscpu.txt` file to your local machine using `scp`:
    ```bash
    scp username@server:lscpu.txt path/to/your/local/repo/hwk/username/
    ```
5. Add the `lscpu.txt` file to the homework git repository, commit the change, and push the change to the remote repository.
6. Submit your homework by creating a pull request to the original repository.
7. Please check your email for the feedback from the instructor or the TA. Once the feedback is received, please update your homework and submit it again. Your homework will be graded after the PR is merged.
